//
//  UITabControl.h
//  scdemo
//
//  Created by fengsh on 3/6/15.
//  Copyright (c) 2015年 fengsh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITabControl : UIView
///设置显示的第几个View,默认为0
@property (nonatomic, assign) NSInteger                 selectedIndex;
///如果addTabView添加的是UIScrollView的子类时则此属性设为NO,防止滚动冲突,default YES.
@property (nonatomic, assign) BOOL                      scrollEnable;

- (void)addTabView:(UIView *)view;
- (void)removeView:(UIView *)view;
- (void)removeViewAtIndex:(NSInteger)index;

- (void)next:(BOOL)animate;
- (void)previous:(BOOL)animate;
- (void)scrollToTop:(BOOL)animate;

@end
