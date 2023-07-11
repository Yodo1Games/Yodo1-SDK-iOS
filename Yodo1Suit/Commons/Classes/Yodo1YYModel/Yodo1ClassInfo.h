//
//  Yodo1ClassInfo.h
//  Yodo1Model <https://github.com/ibireme/Yodo1Model>
//
//  Created by ibireme on 15/5/9.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Type encoding's type.
 */
typedef NS_OPTIONS(NSUInteger, Yodo1EncodingType) {
    Yodo1EncodingTypeMask       = 0xFF, ///< mask of type value
    Yodo1EncodingTypeUnknown    = 0, ///< unknown
    Yodo1EncodingTypeVoid       = 1, ///< void
    Yodo1EncodingTypeBool       = 2, ///< bool
    Yodo1EncodingTypeInt8       = 3, ///< char / BOOL
    Yodo1EncodingTypeUInt8      = 4, ///< unsigned char
    Yodo1EncodingTypeInt16      = 5, ///< short
    Yodo1EncodingTypeUInt16     = 6, ///< unsigned short
    Yodo1EncodingTypeInt32      = 7, ///< int
    Yodo1EncodingTypeUInt32     = 8, ///< unsigned int
    Yodo1EncodingTypeInt64      = 9, ///< long long
    Yodo1EncodingTypeUInt64     = 10, ///< unsigned long long
    Yodo1EncodingTypeFloat      = 11, ///< float
    Yodo1EncodingTypeDouble     = 12, ///< double
    Yodo1EncodingTypeLongDouble = 13, ///< long double
    Yodo1EncodingTypeObject     = 14, ///< id
    Yodo1EncodingTypeClass      = 15, ///< Class
    Yodo1EncodingTypeSEL        = 16, ///< SEL
    Yodo1EncodingTypeBlock      = 17, ///< block
    Yodo1EncodingTypePointer    = 18, ///< void*
    Yodo1EncodingTypeStruct     = 19, ///< struct
    Yodo1EncodingTypeUnion      = 20, ///< union
    Yodo1EncodingTypeCString    = 21, ///< char*
    Yodo1EncodingTypeCArray     = 22, ///< char[10] (for example)
    
    Yodo1EncodingTypeQualifierMask   = 0xFF00,   ///< mask of qualifier
    Yodo1EncodingTypeQualifierConst  = 1 << 8,  ///< const
    Yodo1EncodingTypeQualifierIn     = 1 << 9,  ///< in
    Yodo1EncodingTypeQualifierInout  = 1 << 10, ///< inout
    Yodo1EncodingTypeQualifierOut    = 1 << 11, ///< out
    Yodo1EncodingTypeQualifierBycopy = 1 << 12, ///< bycopy
    Yodo1EncodingTypeQualifierByref  = 1 << 13, ///< byref
    Yodo1EncodingTypeQualifierOneway = 1 << 14, ///< oneway
    
    Yodo1EncodingTypePropertyMask         = 0xFF0000, ///< mask of property
    Yodo1EncodingTypePropertyReadonly     = 1 << 16, ///< readonly
    Yodo1EncodingTypePropertyCopy         = 1 << 17, ///< copy
    Yodo1EncodingTypePropertyRetain       = 1 << 18, ///< retain
    Yodo1EncodingTypePropertyNonatomic    = 1 << 19, ///< nonatomic
    Yodo1EncodingTypePropertyWeak         = 1 << 20, ///< weak
    Yodo1EncodingTypePropertyCustomGetter = 1 << 21, ///< getter=
    Yodo1EncodingTypePropertyCustomSetter = 1 << 22, ///< setter=
    Yodo1EncodingTypePropertyDynamic      = 1 << 23, ///< @dynamic
};

/**
 Get the type from a Type-Encoding string.
 
 @discussion See also:
 https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
 https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html
 
 @param typeEncoding  A Type-Encoding string.
 @return The encoding type.
 */
Yodo1EncodingType Yodo1EncodingGetType(const char *typeEncoding);


/**
 Instance variable information.
 */
@interface Yodo1ClassIvarInfo : NSObject
@property (nonatomic, assign, readonly) Ivar ivar;              ///< ivar opaque struct
@property (nonatomic, strong, readonly) NSString *name;         ///< Ivar's name
@property (nonatomic, assign, readonly) ptrdiff_t offset;       ///< Ivar's offset
@property (nonatomic, strong, readonly) NSString *typeEncoding; ///< Ivar's type encoding
@property (nonatomic, assign, readonly) Yodo1EncodingType type;    ///< Ivar's type

/**
 Creates and returns an ivar info object.
 
 @param ivar ivar opaque struct
 @return A new object, or nil if an error occurs.
 */
- (instancetype)initWithIvar:(Ivar)ivar;
@end


/**
 Method information.
 */
@interface Yodo1ClassMethodInfo : NSObject
@property (nonatomic, assign, readonly) Method method;                  ///< method opaque struct
@property (nonatomic, strong, readonly) NSString *name;                 ///< method name
@property (nonatomic, assign, readonly) SEL sel;                        ///< method's selector
@property (nonatomic, assign, readonly) IMP imp;                        ///< method's implementation
@property (nonatomic, strong, readonly) NSString *typeEncoding;         ///< method's parameter and return types
@property (nonatomic, strong, readonly) NSString *returnTypeEncoding;   ///< return value's type
@property (nullable, nonatomic, strong, readonly) NSArray<NSString *> *argumentTypeEncodings; ///< array of arguments' type

/**
 Creates and returns a method info object.
 
 @param method method opaque struct
 @return A new object, or nil if an error occurs.
 */
- (instancetype)initWithMethod:(Method)method;
@end


/**
 Property information.
 */
@interface Yodo1ClassPropertyInfo : NSObject
@property (nonatomic, assign, readonly) objc_property_t property; ///< property's opaque struct
@property (nonatomic, strong, readonly) NSString *name;           ///< property's name
@property (nonatomic, assign, readonly) Yodo1EncodingType type;      ///< property's type
@property (nonatomic, strong, readonly) NSString *typeEncoding;   ///< property's encoding value
@property (nonatomic, strong, readonly) NSString *ivarName;       ///< property's ivar name
@property (nullable, nonatomic, assign, readonly) Class cls;      ///< may be nil
@property (nullable, nonatomic, strong, readonly) NSArray<NSString *> *protocols; ///< may nil
@property (nonatomic, assign, readonly) SEL getter;               ///< getter (nonnull)
@property (nonatomic, assign, readonly) SEL setter;               ///< setter (nonnull)

/**
 Creates and returns a property info object.
 
 @param property property opaque struct
 @return A new object, or nil if an error occurs.
 */
- (instancetype)initWithProperty:(objc_property_t)property;
@end


/**
 Class information for a class.
 */
@interface Yodo1ClassInfo : NSObject
@property (nonatomic, assign, readonly) Class cls; ///< class object
@property (nullable, nonatomic, assign, readonly) Class superCls; ///< super class object
@property (nullable, nonatomic, assign, readonly) Class metaCls;  ///< class's meta class object
@property (nonatomic, readonly) BOOL isMeta; ///< whether this class is meta class
@property (nonatomic, strong, readonly) NSString *name; ///< class name
@property (nullable, nonatomic, strong, readonly) Yodo1ClassInfo *superClassInfo; ///< super class's class info
@property (nullable, nonatomic, strong, readonly) NSDictionary<NSString *, Yodo1ClassIvarInfo *> *ivarInfos; ///< ivars
@property (nullable, nonatomic, strong, readonly) NSDictionary<NSString *, Yodo1ClassMethodInfo *> *methodInfos; ///< methods
@property (nullable, nonatomic, strong, readonly) NSDictionary<NSString *, Yodo1ClassPropertyInfo *> *propertyInfos; ///< properties

/**
 If the class is changed (for example: you add a method to this class with
 'class_addMethod()'), you should call this method to refresh the class info cache.
 
 After called this method, `needUpdate` will returns `YES`, and you should call 
 'classInfoWithClass' or 'classInfoWithClassName' to get the updated class info.
 */
- (void)setNeedUpdate;

/**
 If this method returns `YES`, you should stop using this instance and call
 `classInfoWithClass` or `classInfoWithClassName` to get the updated class info.
 
 @return Whether this class info need update.
 */
- (BOOL)needUpdate;

/**
 Get the class info of a specified Class.
 
 @discussion This method will cache the class info and super-class info
 at the first access to the Class. This method is thread-safe.
 
 @param cls A class.
 @return A class info, or nil if an error occurs.
 */
+ (nullable instancetype)classInfoWithClass:(Class)cls;

/**
 Get the class info of a specified Class.
 
 @discussion This method will cache the class info and super-class info
 at the first access to the Class. This method is thread-safe.
 
 @param className A class name.
 @return A class info, or nil if an error occurs.
 */
+ (nullable instancetype)classInfoWithClassName:(NSString *)className;

@end

NS_ASSUME_NONNULL_END
