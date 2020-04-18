//
//  ZLBaseEventModel.h
//  ZLCollectionView
//
//  Created by hqtech on 2020/4/18.
//  Copyright © 2020 zhaoliang chen. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZLBaseEventModel : NSObject

@property(nonatomic,copy)NSString* _Nullable eventName;
@property(nonatomic,strong)id _Nullable parameter;

- (instancetype)initWithEventName:(NSString* _Nullable)eventName;
- (instancetype)initWithEventName:(NSString* _Nullable)eventName parameter:(id _Nullable)parameter;
+ (instancetype)createWithEventName:(NSString* _Nullable)eventName;
+ (instancetype)createWithEventName:(NSString* _Nullable)eventName parameter:(id _Nullable)parameter;

@end

NS_ASSUME_NONNULL_END
