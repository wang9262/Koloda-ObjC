#KolodaView-ObjC
This is a Objective-C version of [KolodaView](https://github.com/Yalantis/Koloda).You can see more info at that page.

Thanks
------
First of all,thanks to the great work of [Yalantis](https://github.com/Yalantis).Recently I have been work with the similar things,but mine is not so elegant.So I tried some tinder-like repositories,however they can't satisfy my demand.And then I found [KolodaView](https://github.com/Yalantis/Koloda),but it written in Swift, but my project was under ObjC,so I rewrite this using ObjC.

TODO
-----
- [ ] More Customizable
- [ ] Translate this two articles which explain more details about how this framework works.[article1](https://yalantis.com/blog/how-we-built-tinder-like-koloda-in-swift/)  [article2](https://yalantis.com/blog/koloda-tinder-like-animation-version-2-prototyping-in-pixate-and-development-in-swift/)

Supported OS & SDK Versions
-----------------------------

* Supported build target - iOS 8.0 (Xcode 6.2)
* You can try it on iOS7,it should be work.


ARC Compatibility
------------------

KolodaView-Objc requires ARC. 

Properties
--------------

The SwipeView has the following properties:

```Objective-C
@property (nonatomic, weak) IBOutlet id<SwipeViewDataSource> dataSource;
```
An object that supports the SwipeViewDataSource protocol and can provide views to populate the SwipeView.

```Objective
	@property (nonatomic, weak) IBOutlet id<SwipeDelegate> delegate;
```
An object that supports the SwipeViewDelegate protocol and can respond to SwipeView events.

```Objective-C
@property (nonatomic, readonly) NSUInteger currentCardNum;
```
The index of front card in the SwipeView (read only).

```Objective-C
@property (nonatomic, readonly) NSUInteger cardsCount;
```    

The count of cards in the SwipeView (read only). To set this, implement the `swipeViewNumberOfCards:` dataSource method. 

```Objective-C
    @property (nonatomic, readonly) NSUInteger visibleCardsCount;
```
The count of displayed cards in the SwipeView.
	
Methods
--------------

The SwipeView class has the following methods:

```Objective-C
	- (void)reloadData;
```
This reloads all SwipeView item views from the dataSource and refreshes the display.

```Objective-C
	- (void)revertAction;
```	
Applies undo animation and decrement currentCardNumber.

```Objective-C
	- (void)applyAppearAnimation;
```
Applies appear animation.

```Objective-C
- (void)swipeLeft;
```
Applies swipe left animation and action, increment currentCardNumber.

```Objective-C
- (void)swipeRight;
```
Applies swipe right animation and action, increment currentCardNumber.

```Objective-C
- (CGRect)frameForCardAtIndex:(NSUInteger)index;
 
```
Calculates frames for cards. Useful for overriding. See example to learn more about it.

Protocols
---------------
The SwipeView follows the Apple convention for data-driven views by providing two protocol interfaces, SwipeDataSource and SwipeViewDelegate. 
You can set them through Xib/StoryBoard/Code.All are fine.The SwipeViewDataSource protocol has the following methods:

```Objective-C
- (NSUInteger)swipeViewNumberOfCards:(SwipeView *)swipeView;
```

Return the number of items (views) in the SwipeView.

```Objective-C
- (UIView *)swipeView:(SwipeView *)swipeView
          cardAtIndex:(NSUInteger)index;
```
Return a view to be displayed at the specified index in the SwipeView. 

```Objective-C
- (OverlayView *)swipeView:(SwipeView *)swipeView
        cardOverlayAtIndex:(NSUInteger)index;
```   
Return a view for card overlay at the specified index. For setting custom overlay action on swiping(left/right), you should override didSet of overlayState property in OverlayView. (See Example)

The SwipeViewDelegate protocol has the following methods:

```Objective-C    
 - (void)swipeView:(SwipeView *)swipeView didSwipeCardAtIndex:(NSUInteger)index inDirection:(SwipeDirection)direction;
```    
This method is called whenever the SwipeView swipes card. It is called regardless of whether the card was swiped programatically or through user interaction.

```Objective-C
- (void)swipeViewDidRunOutOfCards:(SwipeView *)swipeView;
```    
This method is called when the SwipeView has no cards to display.

```Objective-C
- (void)swipeView:(SwipeView *)swipeView didSelectCardAtIndex:(NSUInteger)index;
```
This method is called when one of cards is tapped.

```Objective-C
- (BOOL)swipeViewShouldApplyAppearAnimation:(SwipeView *)swipeView;
```
This method is fired on reload, when any cards are displayed. If you return YES from the method, the koloda will apply appear animation.

```Objective-C
- (BOOL)swipeViewShouldMoveBackgroundCard:(SwipeView *)swipeView;
```
This method is fired on start of front card swipping. If you return YES from the method, the koloda will move background card with dragging of front card.

```Objective-C
- (BOOL)swipeViewShouldTransparentizeNextCard:(SwipeView *)swipeView;
```
This method is fired on koloda's layout and after swiping. If you return YES from the method, the koloda will transparentize next card below front card.

```Objective-C
- (POPPropertyAnimation *)swipeViewBackgroundCardAnimation:(SwipeView *)swipeView;
```
Return a pop frame animation to be applied to backround cards after swipe. This method is fired on swipping, when any cards are displayed. If you don't return frame animation, or return nil, the koloda will apply default animation.

License
----------------

    The MIT License (MIT)

    Copyright © 2015 Yalantis

    Permission is hereby granted free of charge to any person obtaining a copy of this software and associated documentation files (the "Software") to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.


