//
//  SwipeView.h
//  Koloda-ObjC
//
//  Created by Vong on 15/8/17.
//  Copyright (c) 2015年 Vong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <POP.h>
#import "DraggableCardView.h"

@class OverlayView;
@protocol SwipeDelegate, SwipeViewDataSource;

@interface SwipeView : UIView

@property (nonatomic, weak) IBOutlet id<SwipeDelegate> delegate;
@property (nonatomic, weak) IBOutlet id<SwipeViewDataSource> dataSource;

@property (nonatomic, readonly) NSUInteger visibleCardsCount;
@property (nonatomic, readonly) NSUInteger cardsCount;
@property (nonatomic, readonly) NSUInteger currentCardNum;

- (CGRect)frameForCardAtIndex:(NSUInteger)index;
- (void)reloadData;
- (void)applyAppearAnimation;
- (void)applyRevertAnimationForCard:(DraggableCardView *)card;
- (void)swipeDirection:(SwipeDirection)direction;
- (void)revertAction;
- (void)resetCurrentCardNumber;

@end

@protocol SwipeViewDataSource <NSObject>

@required
- (NSUInteger)swipeViewNumberOfCards:(SwipeView *)swipeView;
- (UIView *)swipeView:(SwipeView *)swipeView
          cardAtIndex:(NSUInteger)index;
- (OverlayView *)swipeView:(SwipeView *)swipeView
        cardOverlayAtIndex:(NSUInteger)index;

@end

@protocol SwipeDelegate <NSObject>

- (void)swipeView:(SwipeView *)swipeView didSwipeCardAtIndex:(NSUInteger)index inDirection:(SwipeDirection)direction;
- (void)swipeViewDidRunOutOfCards:(SwipeView *)swipeView;
- (void)swipeView:(SwipeView *)swipeView didSelectCardAtIndex:(NSUInteger)index;
- (BOOL)swipeViewShouldApplyAppearAnimation:(SwipeView *)swipeView;
- (BOOL)swipeViewShouldMoveBackgroundCard:(SwipeView *)swipeView;
- (BOOL)swipeViewShouldTransparentizeNextCard:(SwipeView *)swipeView;
- (POPPropertyAnimation *)swipeViewBackgroundCardAnimation:(SwipeView *)swipeView;

@end