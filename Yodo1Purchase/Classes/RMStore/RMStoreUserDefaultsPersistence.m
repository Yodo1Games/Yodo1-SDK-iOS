//
//  RMStoreUserDefaultsPersistence.m
//  RMStore
//
//  Created by Hermes on 10/16/13.
//  Copyright (c) 2013 Robot Media. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "RMStoreUserDefaultsPersistence.h"
#import "RMStoreTransaction.h"
#import "Yodo1UCenter.h"
#import "Yodo1Tool+Storage.h"
#import "Yodo1Tool+Commons.h"
#import "Yodo1PurchaseManager.h"
#import "Yodo1Base.h"

NSString* const RMStoreTransactionsUserDefaultsKey = @"RMStoreTransactions";

@implementation RMStoreUserDefaultsPersistence

#pragma mark - RMStoreTransactionPersistor

- (void)persistTransaction:(SKPaymentTransaction*)paymentTransaction
{
    NSUserDefaults *defaults = [self userDefaults];
    NSDictionary *purchases = [defaults objectForKey:RMStoreTransactionsUserDefaultsKey] ? : @{};
    
    SKPayment *payment = paymentTransaction.payment;
    NSString *productIdentifier = payment.productIdentifier;
    
    NSArray *transactions = purchases[productIdentifier] ? : @[];
    NSMutableArray *updatedTransactions = [NSMutableArray arrayWithArray:transactions];
    
    __block RMStoreTransaction *transaction = [[RMStoreTransaction alloc] initWithPaymentTransaction:paymentTransaction];
    
    NSString* oldOrderIdStr = [Yd1OpsTools keychainWithService:productIdentifier];
    NSArray* oldOrderId = (NSArray *)[Yd1OpsTools JSONObjectWithString:oldOrderIdStr error:nil];
    NSMutableArray* newOrderId = [NSMutableArray array];
    if (oldOrderId) {
        [newOrderId setArray:oldOrderId];
    }
    for (NSString* oderid in oldOrderId) {
        if ([oderid isEqualToString:Yodo1UCenter.shared.itemInfo.orderId]) {
            transaction.orderId = oderid;
            [newOrderId removeObject:oderid];
            break;
        }
        transaction.orderId = oderid;
        [newOrderId removeObject:oderid];
        break;
    }
    NSString* orderidJson = [Yd1OpsTools stringWithJSONObject:newOrderId error:nil];
    [Yd1OpsTools saveKeychainWithService:productIdentifier str:orderidJson];
    __weak typeof(self) weakSelf = self;
    if (!transaction.orderId) { //杀死进程/重新安装应用
        NSString* uniformProductId = [Yodo1PurchaseManager.shared uniformProductIdWithChannelProductId:productIdentifier];
        [Yodo1PurchaseManager.shared createOrderIdWithUniformProductId:uniformProductId
                                                                 extra:@""
                                                              callback:^(bool success, NSString * _Nonnull orderid, NSError * _Nonnull error) {
            if (success) {
                transaction.orderId = orderid;
                NSData *data = [weakSelf dataWithTransaction:transaction];
                [updatedTransactions addObject:data];
                [weakSelf setTransactions:updatedTransactions forProductIdentifier:productIdentifier];
            }else{
                YD1LOG(@"[ 创建订单失败 ]error:%@",error);
            }
        }];
    } else {
        NSData *data = [self dataWithTransaction:transaction];
        [updatedTransactions addObject:data];
        [self setTransactions:updatedTransactions forProductIdentifier:productIdentifier];
    }
}

#pragma mark - Public

- (void)removeTransactions
{
    NSUserDefaults *defaults = [self userDefaults];
    [defaults removeObjectForKey:RMStoreTransactionsUserDefaultsKey];
    [defaults synchronize];
}

- (BOOL)consumeProductOfIdentifier:(NSString*)productIdentifier
{
    NSUserDefaults *defaults = [self userDefaults];
    NSDictionary *purchases = [defaults objectForKey:RMStoreTransactionsUserDefaultsKey] ? : @{};
    NSArray *transactions = purchases[productIdentifier] ? : @[];
    for (NSData *data in transactions)
    {
        RMStoreTransaction *transaction = [self transactionWithData:data];
        if (!transaction.consumed)
        {
            transaction.consumed = YES;
            NSData *updatedData = [self dataWithTransaction:transaction];
            NSMutableArray *updatedTransactions = [NSMutableArray arrayWithArray:transactions];
            NSInteger index = [updatedTransactions indexOfObject:data];
            updatedTransactions[index] = updatedData;
            [self setTransactions:updatedTransactions forProductIdentifier:productIdentifier];
            return YES;
        }
    }
    return NO;
}

- (BOOL)consumeProductOfOrderId:(NSString *)orderId {
    NSSet* productIdentifiers = [self purchasedProductIdentifiers];
    for (NSString* productIdentifier in productIdentifiers.allObjects) {
        NSArray* transactions = [self transactionsForProductOfIdentifier:productIdentifier];
        for (RMStoreTransaction* transaction in transactions) {
            if ([transaction.orderId isEqual:orderId]) {
                [self consumeProductOfIdentifier:productIdentifier];
                return YES;
            }
        }
    }
    return NO;
}

- (BOOL)rechargedProuctOfIdentifier:(NSString *)productIdentifier {
    NSUserDefaults *defaults = [self userDefaults];
    NSDictionary *purchases = [defaults objectForKey:RMStoreTransactionsUserDefaultsKey] ? : @{};
    NSArray *transactions = purchases[productIdentifier] ? : @[];
    for (NSData *data in transactions)
    {
        RMStoreTransaction *transaction = [self transactionWithData:data];
        if (!transaction.recharged)
        {
            transaction.recharged = YES;
            NSData *updatedData = [self dataWithTransaction:transaction];
            NSMutableArray *updatedTransactions = [NSMutableArray arrayWithArray:transactions];
            NSInteger index = [updatedTransactions indexOfObject:data];
            updatedTransactions[index] = updatedData;
            [self setTransactions:updatedTransactions forProductIdentifier:productIdentifier];
            return YES;
        }
    }
    return NO;
}

- (NSInteger)countProductOfdentifier:(NSString*)productIdentifier
{
    NSArray *transactions = [self transactionsForProductOfIdentifier:productIdentifier];
    NSInteger count = 0;
    for (RMStoreTransaction *transaction in transactions)
    {
        if (!transaction.consumed) { count++; }
    }
    return count;
}

- (BOOL)isPurchasedProductOfIdentifier:(NSString*)productIdentifier
{
    NSArray *transactions = [self transactionsForProductOfIdentifier:productIdentifier];
    return transactions.count > 0;
}

- (NSSet*)purchasedProductIdentifiers
{
    NSUserDefaults *defaults = [self userDefaults];
    NSDictionary *purchases = [defaults objectForKey:RMStoreTransactionsUserDefaultsKey];
    NSSet *productIdentifiers = [NSSet setWithArray:purchases.allKeys];
    return productIdentifiers;
}

- (NSArray*)transactionsForProductOfIdentifier:(NSString*)productIdentifier
{
    NSUserDefaults *defaults = [self userDefaults];
    NSDictionary *purchases = [defaults objectForKey:RMStoreTransactionsUserDefaultsKey];
    NSArray *obfuscatedTransactions = purchases[productIdentifier] ? : @[];
    NSMutableArray *transactions = [NSMutableArray arrayWithCapacity:obfuscatedTransactions.count];
    for (NSData *data in obfuscatedTransactions)
    {
        RMStoreTransaction *transaction = [self transactionWithData:data];
        [transactions addObject:transaction];
    }
    return transactions;
}

- (NSUserDefaults *)userDefaults
{
    return [NSUserDefaults standardUserDefaults];
}

#pragma mark - Obfuscation

- (NSData*)dataWithTransaction:(RMStoreTransaction*)transaction
{
    NSData *data = nil;
    NSError *error = nil;
    if (@available(iOS 11.0, *)) {
        data = [NSKeyedArchiver archivedDataWithRootObject:transaction requiringSecureCoding:YES error:&error];
        if (error){
            YD1LOG(@"[ Yodo1 ] save data. error:%@",error);
        }
    } else {
        data = [NSKeyedArchiver archivedDataWithRootObject:transaction];
    }
    return data;
}

- (RMStoreTransaction*)transactionWithData:(NSData*)data
{
    NSError *error = nil;
    RMStoreTransaction* transaction = nil;
    NSSet* sets = [NSSet setWithArray:@[NSArray.class,
                                        NSDictionary.class,
                                        RMStoreTransaction.class,
                                        NSDate.class]];
    if (@available(iOS 11.0, *)) {
        transaction = [NSKeyedUnarchiver unarchivedObjectOfClasses:sets fromData:data error:&error];
        if (error) {
            YD1LOG(@"[ Yodo1 ] loading data. error:%@",error);
        }
    } else {
        transaction = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return transaction;
}

#pragma mark - Private

- (void)setTransactions:(NSArray*)transactions forProductIdentifier:(NSString*)productIdentifier
{
    NSUserDefaults *defaults = [self userDefaults];
    NSDictionary *purchases = [defaults objectForKey:RMStoreTransactionsUserDefaultsKey] ? : @{};
    NSMutableDictionary *updatedPurchases = [NSMutableDictionary dictionaryWithDictionary:purchases];
    updatedPurchases[productIdentifier] = transactions;
    [defaults setObject:updatedPurchases forKey:RMStoreTransactionsUserDefaultsKey];
    [defaults synchronize];
}

@end
