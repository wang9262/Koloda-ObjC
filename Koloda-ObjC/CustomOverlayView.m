//
//  CustomOverlayView.m
//  Koloda-ObjC
//
//  Created by Vong on 15/8/18.
//  Copyright (c) 2015年 Vong. All rights reserved.
//

#import "CustomOverlayView.h"

@interface CustomOverlayView ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation CustomOverlayView

- (void)setType:(OverlayType)type
{
    switch (type) {
        case OverlayTypeLeft:

            self.imageView.image = [UIImage imageNamed:@"noOverlayImage"];
            break;
        case OverlayTypeRight:
            self.imageView.image = [UIImage imageNamed:@"yesOverlayImage"];
            break;
        case OverlayTypeNone:
        default:
            self.imageView.image = nil;
            break;
    }
}

@end
