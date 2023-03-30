//
//  Yodo1Model.h
//  Yodo1Model <https://github.com/ibireme/Yodo1Model>
//
//  Created by ibireme on 15/5/10.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import <Foundation/Foundation.h>

#if __has_include(<Yodo1Model/Yodo1Model.h>)
FOUNDATION_EXPORT double Yodo1ModelVersionNumber;
FOUNDATION_EXPORT const unsigned char Yodo1ModelVersionString[];
#import <Yodo1Model/NSObject+Yodo1Model.h>
#import <Yodo1Model/Yodo1ClassInfo.h>
#else
#import "NSObject+Yodo1Model.h"
#import "Yodo1ClassInfo.h"
#endif
