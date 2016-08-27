//
//  SwipeView.m
//  Koloda-ObjC
//
//  Created by Vong on 15/8/17.
//  Copyright (c) 2015年 Vong. All rights reserved.
//

#import "SwipeView.h"
#import "OverlayView.h"

static CGFloat const  kBackgroundCardsTopMargin                   = 4.0;
static CGFloat const  kBackgroundCardsScalePercent                = 0.95;
static CGFloat const  kBackgroundCardsLeftMargin                  = 8.0;
static NSUInteger const kDefaultCountOfVisibleCards               = 3;

static NSTimeInterval const kBackgroundCardFrameAnimationDuration = 0.2;
static CGFloat const kAppearScaleAnimationFromValue               = 0.1;
static CGFloat const kAppearScaleAnimationToValue                 = 1.0;
static NSTimeInterval const kAppearScaleAnimationDuration         = 0.8;
static NSString *const kAppearScaleAnimationName                  = @"AppearScaleAnimation";


static NSString *const kRevertCardAnimationName                   = @"RevertAlphaAnimation";
static NSTimeInterval const kRevertCardAnimationDuration          = 1.0;
static CGFloat const kRevertCardAnimationToValue                  = 1.0;
static CGFloat const kRevertCardAnimationFromValue                = 0.0;

static NSString *const kAppearAlphaAnimationName                  = @"AppearAlphaAnimation";
static CGFloat const kAppearAlphaAnimationFromValue               = 0.0;
static CGFloat const kAppearAlphaAnimationToValue                 = 1.0;
static NSTimeInterval const kAppearAlphaAnimationDuration         = 0.8;

//Opacity values
static CGFloat const kDefaultAlphaValueOpaque                     = 1.0;
static CGFloat const kDefaultAlphaValueTransparent                = 0.0;
static CGFloat const kDefaultAlphaValueSemiTransparent            = 0.7;

@interface SwipeView () <DraggableCardDelegate>

@property (nonatomic, assign) CGPoint appearScaleAnimationFromValue;
@property (nonatomic, assign) CGPoint appearScaleAnimationToValue;
@property (nonatomic, assign) CGFloat alphaValueOpaque;
@property (nonatomic, assign) CGFloat alphaValueTransparent;
@property (nonatomic, assign) CGFloat alphaValueSemiTransparent;

@property (nonatomic, assign) NSUInteger visibleCardsCount;
@property (nonatomic, assign) NSUInteger cardsCount;
@property (nonatomic, assign) NSUInteger currentCardNum;

@property (nonatomic, assign) BOOL isAnimating;
@property (nonatomic, assign) BOOL hasConfigured;
@property (nonatomic, strong) NSMutableArray *visibleCardsViewArray;

@end

@implementation SwipeView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)init
{
    if (self = [self initWithFrame:CGRectZero]) {
        
    }
    return self;
}

- (void)commonInit
{
    self.appearScaleAnimationFromValue = CGPointMake(kAppearScaleAnimationFromValue, kAppearScaleAnimationFromValue);
    self.appearScaleAnimationToValue = CGPointMake(kAppearScaleAnimationToValue, kAppearScaleAnimationToValue);
    self.alphaValueOpaque = kDefaultAlphaValueOpaque;
    self.alphaValueTransparent = kDefaultAlphaValueTransparent;
    self.alphaValueSemiTransparent = kDefaultAlphaValueSemiTransparent;
    self.visibleCardsViewArray = [NSMutableArray array];
    self.currentCardNum = 0;
    self.visibleCardsCount = kDefaultCountOfVisibleCards;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (!self.hasConfigured) {
        if (self.visibleCardsViewArray.count == 0) {
            [self reloadData];
        }
        else {
            [self setCardViewsFrame];
        }
        self.hasConfigured = YES;
    }
}

#pragma mark - Custom Accessor

- (void)setDataSource:(id<SwipeViewDataSource>)dataSource
{
    if (!dataSource) {
        return;
    }
    NSAssert(dataSource, @"DataSouce cant't be nil");
    _dataSource = dataSource;
    [self setupDeck];
}

#pragma mark - Public

- (CGRect)frameForCardAtIndex:(NSUInteger)index
{
    CGFloat bottomOffset = 0;
    CGFloat topOffset = kBackgroundCardsTopMargin * (self.visibleCardsCount - 1);
    CGFloat xOffset = kBackgroundCardsLeftMargin * index;
    CGFloat scalePercent = kBackgroundCardsScalePercent;
    CGFloat width = CGRectGetWidth(self.frame) * pow(scalePercent, index);
    CGFloat height = (CGRectGetHeight(self.frame) - bottomOffset - topOffset) * pow(scalePercent, index);
    CGFloat multiplier = index > 0 ? 1.0 : 0.0;
    CGRect previousCardFrame = index > 0 ? [self frameForCardAtIndex:MAX(index - 1, 0)] : CGRectZero;
    CGFloat yOffset = (CGRectGetHeight(previousCardFrame) - height + previousCardFrame.origin.y
                       + kBackgroundCardsTopMargin) * multiplier;
    CGRect frame = CGRectMake(xOffset, yOffset, width, height);
    return frame;
}

- (void)reloadData
{
    self.cardsCount = [self.dataSource swipeViewNumberOfCards:self];
    NSUInteger missingCards = MIN(self.visibleCardsCount - self.visibleCardsViewArray.count, self.cardsCount - (self.currentCardNum + 1));
    
    if (self.cardsCount == 0) {
        return;
    }
    
    if (self.currentCardNum == 0) {
        [self cleanUp];
    }
    
    if (self.cardsCount - (self.currentCardNum + self.visibleCardsViewArray.count) > 0) {
        
        if (self.visibleCardsViewArray.count > 0) {
            [self loadMissingCards:missingCards];
        } else {
            [self setupDeck];
            [self setCardViewsFrame];
            if ([self.delegate respondsToSelector:@selector(swipeViewShouldApplyAppearAnimation:)]) {
                BOOL shouldApply = [self.delegate swipeViewShouldApplyAppearAnimation:self];
                if (shouldApply) {
                    self.alpha = 0;
                    [self applyAppearAnimation];
                }
            }
        }
        
    } else {
        [self reconfigureCards];
    }
}

- (void)applyAppearAnimation
{
    self.userInteractionEnabled = NO;
    self.isAnimating = YES;
    
    POPBasicAnimation *scaleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    scaleAnimation.beginTime = CACurrentMediaTime() + 0.4;
    scaleAnimation.duration = kAppearScaleAnimationDuration;
    scaleAnimation.fromValue = [NSValue valueWithCGPoint:self.appearScaleAnimationFromValue];
    scaleAnimation.toValue = [NSValue valueWithCGPoint:self.appearScaleAnimationToValue];
    [scaleAnimation setCompletionBlock:^(POPAnimation *animation, BOOL finished) {
        self.isAnimating = NO;
        self.userInteractionEnabled = YES;
    }];
    [self pop_addAnimation:scaleAnimation forKey:kAppearScaleAnimationName];
    POPBasicAnimation *alphaAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
    
    alphaAnimation.beginTime = CACurrentMediaTime() + 0.4;
    alphaAnimation.fromValue = @(kAppearAlphaAnimationFromValue);
    alphaAnimation.toValue = @(kAppearAlphaAnimationToValue);
    alphaAnimation.duration = kAppearAlphaAnimationDuration;
    
    [self pop_addAnimation:alphaAnimation forKey:kAppearAlphaAnimationName];
}

- (void)applyRevertAnimationForCard:(DraggableCardView *)card {
    self.isAnimating = YES;
    
    POPBasicAnimation *firstCardAppearAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
    
    firstCardAppearAnimation.toValue = @(kRevertCardAnimationToValue);
    firstCardAppearAnimation.fromValue =  @(kRevertCardAnimationFromValue);
    firstCardAppearAnimation.duration = kRevertCardAnimationDuration;
    [firstCardAppearAnimation setCompletionBlock:^(POPAnimation *animation, BOOL finished) {
        self.isAnimating = NO;
    }];
    
    [card pop_addAnimation:firstCardAppearAnimation forKey:kRevertCardAnimationName];
}

- (void)swipeDirection:(SwipeDirection)direction
{
    if (!self.isAnimating) {
        DraggableCardView *frontCard = [self.visibleCardsViewArray firstObject];
        if (frontCard) {
            self.isAnimating = YES;
            if (self.visibleCardsViewArray.count > 1) {
                if ([self.delegate respondsToSelector:@selector(swipeViewShouldTransparentizeNextCard:)]) {
                    BOOL shouldTransparentize = [self.delegate swipeViewShouldTransparentizeNextCard:self];
                    if (shouldTransparentize) {
                        DraggableCardView *nextCard = self.visibleCardsViewArray[1];
                        nextCard.alpha = self.alphaValueOpaque;
                    }
                }
            }
            
            switch (direction) {
            
            case SwipeDirectionLeft:
                [frontCard swipeLeft];
                    break;
            case SwipeDirectionRight:
                [frontCard swipeRight];
                    break;
            case SwipeDirectionNone:
            default:
                    break;
            }
        }
    }
}

- (void)revertAction
{
    if (self.currentCardNum > 0 && !self.isAnimating) {
        
        if (self.cardsCount - self.currentCardNum >= self.visibleCardsCount) {
            DraggableCardView *lastCard = [self.visibleCardsViewArray lastObject];
            if (lastCard) {
                [lastCard removeFromSuperview];
                [self.visibleCardsViewArray removeLastObject];
            }
        }
        
        self.currentCardNum--;
        
        if (self.dataSource) {
            UIView *firstCardContentView = [self.dataSource swipeView:self cardAtIndex:self.currentCardNum];
            OverlayView *firstCardOverlayView = [self.dataSource swipeView:self cardOverlayAtIndex:self.currentCardNum];
            DraggableCardView *firstCardView = [DraggableCardView new];
            
            firstCardView.alpha = self.alphaValueTransparent;
            [firstCardView configWithContentView:firstCardContentView overlayView:firstCardOverlayView];
            firstCardView.delegate = self;
            [self addSubview:firstCardView];
            [self.visibleCardsViewArray insertObject:firstCardView atIndex:0];
            firstCardView.frame = [self frameForCardAtIndex:0];
            [self applyRevertAnimationForCard:firstCardView];
        }
        for (NSInteger index = 0; index < self.visibleCardsViewArray.count; index++) {
            DraggableCardView *currentCard = self.visibleCardsViewArray[index];
            POPBasicAnimation *frameAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewFrame];
            frameAnimation.duration = kBackgroundCardFrameAnimationDuration;
            currentCard.alpha = self.alphaValueSemiTransparent;
            frameAnimation.toValue = [NSValue valueWithCGRect:[self frameForCardAtIndex:index]];
            currentCard.userInteractionEnabled = index == 0;
            [currentCard pop_addAnimation:frameAnimation forKey:@"frameAnimation"];
        }
    }
}

- (void)resetCurrentCardNumber
{
    [self cleanUp];
    [self reloadData];
}

#pragma mark - Private

- (void)setCardViewsFrame
{
    for (NSInteger index = 0; index < self.visibleCardsViewArray.count; index++) {
        DraggableCardView *view = self.visibleCardsViewArray[index];
        view.frame = [self frameForCardAtIndex:index];
    }
}

- (void)setupDeck
{
    self.cardsCount = [self.dataSource swipeViewNumberOfCards:self];
    
    if(self.cardsCount - self.currentCardNum > 0) {
        
        NSUInteger countOfNeededCards = MIN(self.visibleCardsCount, self.cardsCount - self.currentCardNum);
        
        for (NSUInteger index = self.currentCardNum; index < self.currentCardNum + countOfNeededCards; index++) {
            UIView *contentView = [self.dataSource swipeView:self cardAtIndex:index];
            if (contentView) {
                DraggableCardView *nextCardView = [[DraggableCardView alloc] initWithFrame:[self frameForCardAtIndex:index]];
                nextCardView.delegate = self;
                nextCardView.alpha = index == self.currentCardNum ? self.alphaValueOpaque : self.alphaValueSemiTransparent;
                nextCardView.userInteractionEnabled = index == self.currentCardNum;
                
                OverlayView *overlayView = [self.dataSource swipeView:self cardOverlayAtIndex:index];
                [nextCardView configWithContentView:contentView overlayView:overlayView];
                [self.visibleCardsViewArray addObject:nextCardView];
                if (index == self.currentCardNum) {
                    [self addSubview:nextCardView];
                }
                else {
                    [self insertSubview:nextCardView belowSubview:self.visibleCardsViewArray[index - self.currentCardNum - 1]];
                }
            }
        }
    }
}

- (void)cleanUp
{
    self.currentCardNum = 0;
    
    [self.visibleCardsViewArray makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.visibleCardsViewArray removeAllObjects];
}

- (void)loadMissingCards:(NSUInteger)missingCardsCount {
    if (missingCardsCount > 0) {
        
        NSUInteger cardsToAdd = MIN(missingCardsCount, self.cardsCount - self.currentCardNum);
        for (NSUInteger index = 1; index <= cardsToAdd; index ++) {
            DraggableCardView *nextCardView = [[DraggableCardView alloc] initWithFrame:[self frameForCardAtIndex:index]];
            nextCardView.alpha = self.alphaValueSemiTransparent;
            nextCardView.delegate = self;
            [self.visibleCardsViewArray addObject:nextCardView];
            [self insertSubview:nextCardView belowSubview:self.visibleCardsViewArray[index - 1]];
        }
    }
    
    [self reconfigureCards];
}

- (void)reconfigureCards
{
    for (NSUInteger index = 0; index < self.visibleCardsViewArray.count; index ++) {
        if (self.dataSource) {
            
            UIView *currentCardContentView = [self.dataSource swipeView:self cardAtIndex:index + self.currentCardNum];
            OverlayView *overlay = [self.dataSource swipeView:self cardOverlayAtIndex:index + self.currentCardNum];
            DraggableCardView *cardView = self.visibleCardsViewArray[index];
            [cardView configWithContentView:currentCardContentView overlayView:overlay];
        }
    }
}

- (void)moveOtherCardsWithFinishPercent:(CGFloat)percent
{
    if (self.visibleCardsViewArray.count > 1) {
        
        for (NSUInteger index = 1; index < self.visibleCardsViewArray.count; index++) {
            CGRect previousCardFrame = [self frameForCardAtIndex:index - 1];
            CGRect frame = [self frameForCardAtIndex:index];
            CGFloat distanceToMoveY = (frame.origin.y - previousCardFrame.origin.y) * (percent / 100);
            frame.origin.y -= distanceToMoveY;
            CGFloat distanceToMoveX = (previousCardFrame.origin.x - frame.origin.x) * (percent / 100);
            frame.origin.x += distanceToMoveX;
            
            CGFloat widthScale = (previousCardFrame.size.width - frame.size.width) * (percent / 100);
            CGFloat heightScale = (previousCardFrame.size.height - frame.size.height) * (percent / 100);
            
            frame.size.width += widthScale;
            frame.size.height += heightScale;
            
            DraggableCardView *card = self.visibleCardsViewArray[index];
            
            card.frame = frame;
            [card layoutIfNeeded];
            
            //For fully visible next card, when moving top card
            if ([self.delegate respondsToSelector:@selector(swipeViewShouldTransparentizeNextCard:)]) {
                BOOL shouldTransparent = [self.delegate swipeViewShouldTransparentizeNextCard:self];
                if (shouldTransparent && index == 1) {
                    card.alpha = self.alphaValueOpaque;
                }
            }
        }
    }
}

- (void)swipeToDirection:(SwipeDirection)direction
{
    self.isAnimating = YES;
    [self.visibleCardsViewArray removeObjectAtIndex:0];
    self.currentCardNum++;
    NSUInteger shownCardsCount = self.currentCardNum + self.visibleCardsCount;
    if (shownCardsCount - 1 < self.cardsCount) {
        if (self.dataSource) {
            UIView *lastCardContentView = [self.dataSource swipeView:self cardAtIndex:shownCardsCount - 1];
            OverlayView *lastCardOverlayView = [self.dataSource swipeView:self cardOverlayAtIndex:shownCardsCount - 1];
            CGRect lastCardFrame = [self frameForCardAtIndex:self.currentCardNum + self.visibleCardsViewArray.count];
            DraggableCardView *lastCardView = [[DraggableCardView alloc] initWithFrame:lastCardFrame];
            lastCardView.userInteractionEnabled = YES;
            [lastCardView configWithContentView:lastCardContentView overlayView:lastCardOverlayView];
            lastCardView.delegate = self;
            [self insertSubview:lastCardView belowSubview:[self.visibleCardsViewArray lastObject]];
            [self.visibleCardsViewArray addObject:lastCardView];
        }
    }
    
    if (self.visibleCardsViewArray.count > 0) {
        for (NSUInteger index = 0; index < self.visibleCardsViewArray.count; index++) {
            POPPropertyAnimation *frameAnimation = nil;
            DraggableCardView *currentCard = self.visibleCardsViewArray[index];
            if ([self.delegate respondsToSelector:@selector(swipeViewBackgroundCardAnimation:)]) {
                POPPropertyAnimation *delegateAnimation = [self.delegate swipeViewBackgroundCardAnimation:self];
                if ([[[delegateAnimation property] name] isEqualToString:kPOPViewFrame]) {
                    frameAnimation = delegateAnimation;
                }
                else {
                    frameAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewFrame];
                    ((POPBasicAnimation *)frameAnimation).duration = kBackgroundCardFrameAnimationDuration;
                }
            }
            if ([self.delegate respondsToSelector:@selector(swipeViewShouldTransparentizeNextCard:)]) {
                BOOL shouldTransparentize = [self.delegate swipeViewShouldTransparentizeNextCard:self];
                if (index != 0) {
                    currentCard.alpha = self.alphaValueSemiTransparent;
                }
                else {
                    [frameAnimation setCompletionBlock:^(POPAnimation *animation, BOOL finished) {
                        [self.visibleCardsViewArray.lastObject setHidden:NO];
                        self.isAnimating = NO;
                        if ([self.delegate respondsToSelector:@selector(swipeView:didSwipeCardAtIndex:inDirection:)]) {
                            [self.delegate swipeView:self didSwipeCardAtIndex:(self.currentCardNum - 1) inDirection:direction];
                        }
                        if (!shouldTransparentize) {
                            currentCard.alpha = self.alphaValueOpaque;
                        }
                    }];
                    if (shouldTransparentize) {
                        currentCard.alpha = self.alphaValueOpaque;
                    } else {
                        POPBasicAnimation *alphaAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
                        alphaAnimation.toValue = @(self.alphaValueOpaque);
                        alphaAnimation.duration = kBackgroundCardFrameAnimationDuration;
                        [currentCard pop_addAnimation:alphaAnimation forKey:@"alpha"];
                    }
                }
                currentCard.userInteractionEnabled = index == 0;
                frameAnimation.toValue = [NSValue valueWithCGRect:[self frameForCardAtIndex:index]];
                [currentCard pop_addAnimation:frameAnimation forKey:@"frameAnimation"];
            }
        }
    }
    else {
        if ([self.delegate respondsToSelector:@selector(swipeView:didSwipeCardAtIndex:inDirection:)]) {
            [self.delegate swipeView:self didSwipeCardAtIndex:(self.currentCardNum - 1) inDirection:direction];
        }
        self.isAnimating = NO;
        if ([self.delegate respondsToSelector:@selector(swipeViewDidRunOutOfCards:)]) {
            [self.delegate swipeViewDidRunOutOfCards:self];
        }
    }
}

#pragma mark - DraggableCardDelegate

- (void)cardView:(DraggableCardView *)cardView draggedWithFinishPercent:(CGFloat)percent
{
    self.isAnimating = YES;
    if ([self.delegate respondsToSelector:@selector(swipeViewShouldMoveBackgroundCard:)]) {
        BOOL shouldMove = [self.delegate swipeViewShouldMoveBackgroundCard:self];
        if (shouldMove) {
            [self moveOtherCardsWithFinishPercent:percent];
        }
    }
}

- (void)cardView:(DraggableCardView *)cardView swippedInDirection:(SwipeDirection)direction
{
    [self swipeToDirection:direction];
}

- (void)cardViewReset:(DraggableCardView *)cardView
{
    if (self.visibleCardsViewArray.count > 1) {
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            [self moveOtherCardsWithFinishPercent:0];
        } completion:^(BOOL finished) {
            self.isAnimating = NO;
            for (NSInteger index = 1; index < self.visibleCardsViewArray.count; index++) {
                DraggableCardView *card = self.visibleCardsViewArray[index];
                card.alpha = self.alphaValueSemiTransparent;
            }
        }];
    } else {
        self.isAnimating = NO;
    }
}

- (void)cardViewTapped:(DraggableCardView *)cardView
{
    NSUInteger index = self.currentCardNum + [self.visibleCardsViewArray indexOfObjectIdenticalTo:cardView];
    if ([self.delegate respondsToSelector:@selector(swipeView:didSelectCardAtIndex:)]) {
        [self.delegate swipeView:self didSelectCardAtIndex:index];
    }
}

@end
