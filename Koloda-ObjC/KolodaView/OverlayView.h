//
//  OverLayView.h
//  Koloda-ObjC
//
//  Created by Vong on 15/8/17.
//  Copyright (c) 2015年 Vong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, OverlayType) {
    OverlayTypeNone = 0,
    OverlayTypeLeft,
    OverlayTypeRight
};

@interface OverlayView : UIView

@property (nonatomic, assign) OverlayType type;

@end
