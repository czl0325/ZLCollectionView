//
//  ZLBaseEventModel.m
//  ZLCollectionView
//
//  Created by hqtech on 2020/4/18.
//  Copyright © 2020 zhaoliang chen. All rights reserved.
//

#import "ZLBaseEventModel.h"

@implementation ZLBaseEventModel

- (instancetype)initWithEventName:(NSString* _Nullable)eventName {
    return [self initWithEventName:eventName parameter:nil];
}

- (instancetype)initWithEventName:(NSString* _Nullable)eventName parameter:(id _Nullable)parameter {
    if (self == [super init]) {
        self.eventName = eventName;
        self.parameter = parameter;
    }
    return self;
}

+ (instancetype)createWithEventName:(NSString* _Nullable)eventName {
    ZLBaseEventModel* eventModel = [[ZLBaseEventModel alloc]initWithEventName:eventName parameter:nil];
    return eventModel;
}

+ (instancetype)createWithEventName:(NSString* _Nullable)eventName parameter:(id _Nullable)parameter {
    ZLBaseEventModel* eventModel = [[ZLBaseEventModel alloc]initWithEventName:eventName parameter:parameter];
    return eventModel;
}

@end
