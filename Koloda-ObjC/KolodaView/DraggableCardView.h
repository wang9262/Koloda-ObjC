//
//  DraggableCardView.h
//  Koloda-ObjC
//
//  Created by Vong on 15/8/17.
//  Copyright (c) 2015年 Vong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SwipeDirection) {
    SwipeDirectionNone = 0,
    SwipeDirectionLeft,
    SwipeDirectionRight
};

@protocol DraggableCardDelegate;
@class OverlayView;
@interface DraggableCardView : UIView

@property (nonatomic, weak) id<DraggableCardDelegate>delegate;

- (void)configWithContentView:(UIView *)content overlayView:(OverlayView *)overlay;
- (void)swipeLeft;
- (void)swipeRight;

@end

@protocol DraggableCardDelegate <NSObject>

- (void)cardView:(DraggableCardView *)cardView draggedWithFinishPercent:(CGFloat)percent;
- (void)cardView:(DraggableCardView *)cardView swippedInDirection:(SwipeDirection)direction;
- (void)cardViewReset:(DraggableCardView *)cardView;
- (void)cardViewTapped:(DraggableCardView *)cardView;

@end