//
//  UITabControl.m
//  scdemo
//
//  Created by fengsh on 3/6/15.
//  Copyright (c) 2015年 fengsh. All rights reserved.
//

#import "UITabControl.h"


@interface UITabControl()<UIScrollViewDelegate>
{
    UIScrollView            *_containerView;
    NSMutableArray          *_views;
    ///当前已经显示的view数量
    NSInteger               _currntDisplayViewCount;
    NSMutableDictionary     *_pageInfo;
}
@property (nonatomic, assign) BOOL                    hasNext;
@property (nonatomic, assign) BOOL                    hasPrevious;

- (void)scrollToPoint:(CGPoint)offset withAnimate:(BOOL)animate;

@end;

@implementation UITabControl

- (id)init
{
    self = [super init];
    if (self) {
        [self setDefaultValue];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setDefaultValue];
    }
    return self;
}

- (void)setDefaultValue
{
    self.selectedIndex = 0;
    _currntDisplayViewCount = 0;
}

- (void)dealloc
{
    for (NSInteger i = 0;i < self.views.count;i++) {
        [self removeViewAtIndex:i];
    }
    
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (NSMutableArray*)views
{
    if (!_views) {
        _views = [[NSMutableArray alloc]init];
    }
    return _views;
}

- (NSMutableDictionary *)pageInfo
{
    if (!_pageInfo) {
        _pageInfo = [[NSMutableDictionary alloc]init];
    }
    return _pageInfo;
}

- (UIScrollView *)containerView
{
    if (!_containerView) {
        _containerView = [[UIScrollView alloc]init];
        _containerView.backgroundColor = [UIColor grayColor];
        _containerView.clipsToBounds = YES;      //此句话重要，不裁剪到边缘
        _containerView.delegate = self;
        _containerView.showsHorizontalScrollIndicator = YES;
        _containerView.showsVerticalScrollIndicator = YES;
        [self addSubview:_containerView];
    }
    return _containerView;
}

- (BOOL)hasNext
{
    NSLog(@"idx ======== %d",_selectedIndex);
    return _selectedIndex + 1 < self.views.count;
}

- (BOOL)hasPrevious
{
    NSLog(@"idx p ======== %d",_selectedIndex);
    return _selectedIndex > 0;
}

- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    _selectedIndex = selectedIndex;
    [self setNeedsDisplay];
}

- (void)addTabView:(UIView *)view
{
    [self.views addObject:view];
    [self addSubview:view];
    [view addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([object isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scv = object;
        CGFloat offsety = scv.contentOffset.y;
        CGRect frame = scv.frame;
        CGFloat bottompos = (scv.contentSize.height - frame.size.height);

        //NSLog(@",,,,,,,,,,,= %@", NSStringFromUIEdgeInsets(scv.contentInset));
 
        //ios 7上如果设了导航偏移
        if (offsety + scv.contentInset.top < 0) {
            
            NSInteger pageidx = [self indexOfFindView:scv];
            if (pageidx > 0)
            {
                    CGFloat y = frame.origin.y + offsety + scv.contentInset.top;
                    CGPoint pt = CGPointMake(0,y);
                    //NSLog(@"pt ======== %@,offsety %f",NSStringFromCGPoint(pt),offsety);
                    [self.containerView setContentOffset:pt];
            }
        }
        
        if ((offsety - bottompos) > 0)
        {
            CGFloat y = frame.origin.y + (offsety - bottompos);
            CGPoint pt = CGPointMake(0,y);
            //NSLog(@"pt ======== %@",NSStringFromCGPoint(pt));
            [self.containerView setContentOffset:pt];
            
            //scv.contentInset = UIEdgeInsetsMake(-(offsety - bottompos), 0, 0, 0);
            //做晕示下页
            //判断当前页的下一页是否已加载了，如果加载了直接翻页
            //NSLog(@"offsety == %f,frmae = %@, bt = %f",offsety,NSStringFromCGRect(frame),bottompos);
        }
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
//    NSLog(@"xxxxxxx===== %@",NSStringFromCGRect(self.bounds));
    self.containerView.frame = self.bounds;
}

- (NSInteger)indexOfFindView:(UIView *)view
{
    NSInteger idx = NSNotFound;
    
    for (NSInteger i = 0; i < self.views.count; i++) {
        UIView *item = self.views[i];
        if (item == view) {
            idx = i;
            break;
        }
    }
    
    return idx;
}

- (void)removeView:(UIView *)view
{
    NSInteger idx = [self indexOfFindView:view];
    if (idx != NSNotFound) {
        [self removeViewAtIndex:idx];
    }
}

- (void)removeViewAtIndex:(NSInteger)index
{
    UIView *v = self.views[index];
    [v removeObserver:self forKeyPath:@"contentOffset"];
    [self.views removeObjectAtIndex:index];
}

- (void)next:(BOOL)animate
{

    [self performSelector:@selector(dob) withObject:nil afterDelay:0.2];
}

- (void)previous:(BOOL)animate
{
    [self performSelector:@selector(doa) withObject:nil afterDelay:0.2];
}

- (void)scrollToTop:(BOOL)animate
{
    _selectedIndex = 0;
    [self scrollToPageOfIndex:_selectedIndex withAnimate:animate];
}

- (void)doa
{
    if (self.hasPrevious)
    {
        [self scrollToPageOfIndex:--_selectedIndex withAnimate:YES];
    }
    //[self scrollToPageOfIndex:0 withAnimate:animate];
}

- (void)dob
{
    if (self.hasNext)
    {
        [self scrollToPageOfIndex:++_selectedIndex withAnimate:YES];
    }
    //[self scrollToPageOfIndex:1 withAnimate:animate];
}

- (void)scrollToPageOfIndex:(NSInteger)index withAnimate:(BOOL)animate
{
    NSNumber *nboffset = self.pageInfo[[NSString stringWithFormat:@"id_%ld",(long)index]];
    if (nboffset) {
        CGFloat offsety = [nboffset floatValue];
        CGPoint pt = CGPointMake(0, offsety);

        [self scrollToPoint:pt withAnimate:animate];
    }
    else //说明未显示的
    {
        if (index<self.views.count) {
            [self refreshTabView];
            [self scrollToPageOfIndex:index withAnimate:YES];
        }
        else
        {
            --_selectedIndex;
        }
    }
}

- (void)scrollToPoint:(CGPoint)offset withAnimate:(BOOL)animate
{
    NSLog(@"当前页索引  ====== %d",_selectedIndex);
    [UIView animateWithDuration:0.5 animations:^{
        [self.containerView setContentOffset:offset animated:animate];
    }];
    
}

- (void)refreshTabView
{
    [self.containerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    CGFloat fw = CGRectGetWidth(self.frame);
    CGFloat vheight = 0;
    //最大已显示的数量
    _currntDisplayViewCount = MAX(_currntDisplayViewCount, _selectedIndex+1);
    
    for (NSInteger i = 0; i < _currntDisplayViewCount; i++)
    {
        UIView *visableview = self.views[i];
        
        CGRect rt = visableview.frame;
        //刷新分页偏移
        [self.pageInfo setObject:[NSNumber numberWithFloat:vheight]
                          forKey:[NSString stringWithFormat:@"id_%ld",(long)i]];
        rt.origin.y = vheight;
        rt.origin.x = 0;
        rt.size.width = fw;
        rt.size.height = CGRectGetHeight(self.frame);
        vheight += CGRectGetHeight(rt);
        visableview.frame = rt;

        [self.containerView addSubview:visableview];
        
    }
    [self.containerView setContentSize:CGSizeMake(fw, vheight)];
    self.containerView.scrollEnabled = NO;//self.scrollEnable;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    [self refreshTabView];
    [self scrollToPageOfIndex:_selectedIndex withAnimate:NO];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //NSLog(@"xxxxxxxxx == %f",scrollView.contentOffset.y);
}

@end
