//
//  OverLayView.m
//  Koloda-ObjC
//
//  Created by Vong on 15/8/17.
//  Copyright (c) 2015年 Vong. All rights reserved.
//

#import "OverlayView.h"

@implementation OverlayView

- (instancetype)init
{
    if (self = [super init]) {
        self.type = OverlayTypeNone;
    }
    return self;
}

@end
