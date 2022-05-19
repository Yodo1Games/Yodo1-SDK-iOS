//
//  Yodo1ClassInfo.m
//  Yodo1Model <https://github.com/ibireme/Yodo1Model>
//
//  Created by ibireme on 15/5/9.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "Yodo1ClassInfo.h"
#import <objc/runtime.h>

Yodo1EncodingType Yodo1EncodingGetType(const char *typeEncoding) {
    char *type = (char *)typeEncoding;
    if (!type) return Yodo1EncodingTypeUnknown;
    size_t len = strlen(type);
    if (len == 0) return Yodo1EncodingTypeUnknown;
    
    Yodo1EncodingType qualifier = 0;
    bool prefix = true;
    while (prefix) {
        switch (*type) {
            case 'r': {
                qualifier |= Yodo1EncodingTypeQualifierConst;
                type++;
            } break;
            case 'n': {
                qualifier |= Yodo1EncodingTypeQualifierIn;
                type++;
            } break;
            case 'N': {
                qualifier |= Yodo1EncodingTypeQualifierInout;
                type++;
            } break;
            case 'o': {
                qualifier |= Yodo1EncodingTypeQualifierOut;
                type++;
            } break;
            case 'O': {
                qualifier |= Yodo1EncodingTypeQualifierBycopy;
                type++;
            } break;
            case 'R': {
                qualifier |= Yodo1EncodingTypeQualifierByref;
                type++;
            } break;
            case 'V': {
                qualifier |= Yodo1EncodingTypeQualifierOneway;
                type++;
            } break;
            default: { prefix = false; } break;
        }
    }

    len = strlen(type);
    if (len == 0) return Yodo1EncodingTypeUnknown | qualifier;

    switch (*type) {
        case 'v': return Yodo1EncodingTypeVoid | qualifier;
        case 'B': return Yodo1EncodingTypeBool | qualifier;
        case 'c': return Yodo1EncodingTypeInt8 | qualifier;
        case 'C': return Yodo1EncodingTypeUInt8 | qualifier;
        case 's': return Yodo1EncodingTypeInt16 | qualifier;
        case 'S': return Yodo1EncodingTypeUInt16 | qualifier;
        case 'i': return Yodo1EncodingTypeInt32 | qualifier;
        case 'I': return Yodo1EncodingTypeUInt32 | qualifier;
        case 'l': return Yodo1EncodingTypeInt32 | qualifier;
        case 'L': return Yodo1EncodingTypeUInt32 | qualifier;
        case 'q': return Yodo1EncodingTypeInt64 | qualifier;
        case 'Q': return Yodo1EncodingTypeUInt64 | qualifier;
        case 'f': return Yodo1EncodingTypeFloat | qualifier;
        case 'd': return Yodo1EncodingTypeDouble | qualifier;
        case 'D': return Yodo1EncodingTypeLongDouble | qualifier;
        case '#': return Yodo1EncodingTypeClass | qualifier;
        case ':': return Yodo1EncodingTypeSEL | qualifier;
        case '*': return Yodo1EncodingTypeCString | qualifier;
        case '^': return Yodo1EncodingTypePointer | qualifier;
        case '[': return Yodo1EncodingTypeCArray | qualifier;
        case '(': return Yodo1EncodingTypeUnion | qualifier;
        case '{': return Yodo1EncodingTypeStruct | qualifier;
        case '@': {
            if (len == 2 && *(type + 1) == '?')
                return Yodo1EncodingTypeBlock | qualifier;
            else
                return Yodo1EncodingTypeObject | qualifier;
        }
        default: return Yodo1EncodingTypeUnknown | qualifier;
    }
}

@implementation Yodo1ClassIvarInfo

- (instancetype)initWithIvar:(Ivar)ivar {
    if (!ivar) return nil;
    self = [super init];
    _ivar = ivar;
    const char *name = ivar_getName(ivar);
    if (name) {
        _name = [NSString stringWithUTF8String:name];
    }
    _offset = ivar_getOffset(ivar);
    const char *typeEncoding = ivar_getTypeEncoding(ivar);
    if (typeEncoding) {
        _typeEncoding = [NSString stringWithUTF8String:typeEncoding];
        _type = Yodo1EncodingGetType(typeEncoding);
    }
    return self;
}

@end

@implementation Yodo1ClassMethodInfo

- (instancetype)initWithMethod:(Method)method {
    if (!method) return nil;
    self = [super init];
    _method = method;
    _sel = method_getName(method);
    _imp = method_getImplementation(method);
    const char *name = sel_getName(_sel);
    if (name) {
        _name = [NSString stringWithUTF8String:name];
    }
    const char *typeEncoding = method_getTypeEncoding(method);
    if (typeEncoding) {
        _typeEncoding = [NSString stringWithUTF8String:typeEncoding];
    }
    char *returnType = method_copyReturnType(method);
    if (returnType) {
        _returnTypeEncoding = [NSString stringWithUTF8String:returnType];
        free(returnType);
    }
    unsigned int argumentCount = method_getNumberOfArguments(method);
    if (argumentCount > 0) {
        NSMutableArray *argumentTypes = [NSMutableArray new];
        for (unsigned int i = 0; i < argumentCount; i++) {
            char *argumentType = method_copyArgumentType(method, i);
            NSString *type = argumentType ? [NSString stringWithUTF8String:argumentType] : nil;
            [argumentTypes addObject:type ? type : @""];
            if (argumentType) free(argumentType);
        }
        _argumentTypeEncodings = argumentTypes;
    }
    return self;
}

@end

@implementation Yodo1ClassPropertyInfo

- (instancetype)initWithProperty:(objc_property_t)property {
    if (!property) return nil;
    self = [super init];
    _property = property;
    const char *name = property_getName(property);
    if (name) {
        _name = [NSString stringWithUTF8String:name];
    }
    
    Yodo1EncodingType type = 0;
    unsigned int attrCount;
    objc_property_attribute_t *attrs = property_copyAttributeList(property, &attrCount);
    for (unsigned int i = 0; i < attrCount; i++) {
        switch (attrs[i].name[0]) {
            case 'T': { // Type encoding
                if (attrs[i].value) {
                    _typeEncoding = [NSString stringWithUTF8String:attrs[i].value];
                    type = Yodo1EncodingGetType(attrs[i].value);
                    
                    if ((type & Yodo1EncodingTypeMask) == Yodo1EncodingTypeObject && _typeEncoding.length) {
                        NSScanner *scanner = [NSScanner scannerWithString:_typeEncoding];
                        if (![scanner scanString:@"@\"" intoString:NULL]) continue;
                        
                        NSString *clsName = nil;
                        if ([scanner scanUpToCharactersFromSet: [NSCharacterSet characterSetWithCharactersInString:@"\"<"] intoString:&clsName]) {
                            if (clsName.length) _cls = objc_getClass(clsName.UTF8String);
                        }
                        
                        NSMutableArray *protocols = nil;
                        while ([scanner scanString:@"<" intoString:NULL]) {
                            NSString* protocol = nil;
                            if ([scanner scanUpToString:@">" intoString: &protocol]) {
                                if (protocol.length) {
                                    if (!protocols) protocols = [NSMutableArray new];
                                    [protocols addObject:protocol];
                                }
                            }
                            [scanner scanString:@">" intoString:NULL];
                        }
                        _protocols = protocols;
                    }
                }
            } break;
            case 'V': { // Instance variable
                if (attrs[i].value) {
                    _ivarName = [NSString stringWithUTF8String:attrs[i].value];
                }
            } break;
            case 'R': {
                type |= Yodo1EncodingTypePropertyReadonly;
            } break;
            case 'C': {
                type |= Yodo1EncodingTypePropertyCopy;
            } break;
            case '&': {
                type |= Yodo1EncodingTypePropertyRetain;
            } break;
            case 'N': {
                type |= Yodo1EncodingTypePropertyNonatomic;
            } break;
            case 'D': {
                type |= Yodo1EncodingTypePropertyDynamic;
            } break;
            case 'W': {
                type |= Yodo1EncodingTypePropertyWeak;
            } break;
            case 'G': {
                type |= Yodo1EncodingTypePropertyCustomGetter;
                if (attrs[i].value) {
                    _getter = NSSelectorFromString([NSString stringWithUTF8String:attrs[i].value]);
                }
            } break;
            case 'S': {
                type |= Yodo1EncodingTypePropertyCustomSetter;
                if (attrs[i].value) {
                    _setter = NSSelectorFromString([NSString stringWithUTF8String:attrs[i].value]);
                }
            } // break; commented for code coverage in next line
            default: break;
        }
    }
    if (attrs) {
        free(attrs);
        attrs = NULL;
    }
    
    _type = type;
    if (_name.length) {
        if (!_getter) {
            _getter = NSSelectorFromString(_name);
        }
        if (!_setter) {
            _setter = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:", [_name substringToIndex:1].uppercaseString, [_name substringFromIndex:1]]);
        }
    }
    return self;
}

@end

@implementation Yodo1ClassInfo {
    BOOL _needUpdate;
}

- (instancetype)initWithClass:(Class)cls {
    if (!cls) return nil;
    self = [super init];
    _cls = cls;
    _superCls = class_getSuperclass(cls);
    _isMeta = class_isMetaClass(cls);
    if (!_isMeta) {
        _metaCls = objc_getMetaClass(class_getName(cls));
    }
    _name = NSStringFromClass(cls);
    [self _update];

    _superClassInfo = [self.class classInfoWithClass:_superCls];
    return self;
}

- (void)_update {
    _ivarInfos = nil;
    _methodInfos = nil;
    _propertyInfos = nil;
    
    Class cls = self.cls;
    unsigned int methodCount = 0;
    Method *methods = class_copyMethodList(cls, &methodCount);
    if (methods) {
        NSMutableDictionary *methodInfos = [NSMutableDictionary new];
        _methodInfos = methodInfos;
        for (unsigned int i = 0; i < methodCount; i++) {
            Yodo1ClassMethodInfo *info = [[Yodo1ClassMethodInfo alloc] initWithMethod:methods[i]];
            if (info.name) methodInfos[info.name] = info;
        }
        free(methods);
    }
    unsigned int propertyCount = 0;
    objc_property_t *properties = class_copyPropertyList(cls, &propertyCount);
    if (properties) {
        NSMutableDictionary *propertyInfos = [NSMutableDictionary new];
        _propertyInfos = propertyInfos;
        for (unsigned int i = 0; i < propertyCount; i++) {
            Yodo1ClassPropertyInfo *info = [[Yodo1ClassPropertyInfo alloc] initWithProperty:properties[i]];
            if (info.name) propertyInfos[info.name] = info;
        }
        free(properties);
    }
    
    unsigned int ivarCount = 0;
    Ivar *ivars = class_copyIvarList(cls, &ivarCount);
    if (ivars) {
        NSMutableDictionary *ivarInfos = [NSMutableDictionary new];
        _ivarInfos = ivarInfos;
        for (unsigned int i = 0; i < ivarCount; i++) {
            Yodo1ClassIvarInfo *info = [[Yodo1ClassIvarInfo alloc] initWithIvar:ivars[i]];
            if (info.name) ivarInfos[info.name] = info;
        }
        free(ivars);
    }
    
    if (!_ivarInfos) _ivarInfos = @{};
    if (!_methodInfos) _methodInfos = @{};
    if (!_propertyInfos) _propertyInfos = @{};
    
    _needUpdate = NO;
}

- (void)setNeedUpdate {
    _needUpdate = YES;
}

- (BOOL)needUpdate {
    return _needUpdate;
}

+ (instancetype)classInfoWithClass:(Class)cls {
    if (!cls) return nil;
    static CFMutableDictionaryRef classCache;
    static CFMutableDictionaryRef metaCache;
    static dispatch_once_t onceToken;
    static dispatch_semaphore_t lock;
    dispatch_once(&onceToken, ^{
        classCache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        metaCache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        lock = dispatch_semaphore_create(1);
    });
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    Yodo1ClassInfo *info = CFDictionaryGetValue(class_isMetaClass(cls) ? metaCache : classCache, (__bridge const void *)(cls));
    if (info && info->_needUpdate) {
        [info _update];
    }
    dispatch_semaphore_signal(lock);
    if (!info) {
        info = [[Yodo1ClassInfo alloc] initWithClass:cls];
        if (info) {
            dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
            CFDictionarySetValue(info.isMeta ? metaCache : classCache, (__bridge const void *)(cls), (__bridge const void *)(info));
            dispatch_semaphore_signal(lock);
        }
    }
    return info;
}

+ (instancetype)classInfoWithClassName:(NSString *)className {
    Class cls = NSClassFromString(className);
    return [self classInfoWithClass:cls];
}

@end
