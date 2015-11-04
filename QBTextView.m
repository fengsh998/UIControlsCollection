//
//  QBTextView.m
//  QianbaoIM
//
//  Created by fengsh on 30/4/15.
//  Copyright (c) 2015年 qianbao.com. All rights reserved.
//

#import "QBTextView.h"

@interface QBTextView ()
- (void)_initialize;
- (void)_updateShouldDrawPlaceholder;
- (void)_textChanged:(NSNotification *)notification;
@end

@implementation QBTextView
{
    BOOL _shouldDrawPlaceholder;
}

- (void)setText:(NSString *)string {
    [super setText:string];
    [self _updateShouldDrawPlaceholder];
}


- (void)setPlaceholder:(NSString *)string {
    if ([string isEqual:_placeholder]) {
        return;
    }
    
    _placeholder = string;
    [self _updateShouldDrawPlaceholder];
}


#pragma mark - NSObject

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:self];
}


#pragma mark - UIView

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self _initialize];
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self _initialize];
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    if (_shouldDrawPlaceholder) {

        NSDictionary *attribues = @{NSFontAttributeName:self.font,NSForegroundColorAttributeName:_placeholderTextColor};
        
        [_placeholder drawInRect:CGRectMake(8.0f, 8.0f, self.frame.size.width - 16.0f, self.frame.size.height - 16.0f) withAttributes:attribues];
    }
}


#pragma mark - Private

- (void)_initialize {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_textChanged:) name:UITextViewTextDidChangeNotification object:self];
    self.font = [UIFont systemFontOfSize:13.0f];
    self.placeholderTextColor = [UIColor colorWithWhite:0.702f alpha:1.0f];
    _shouldDrawPlaceholder = NO;
}


- (void)_updateShouldDrawPlaceholder {
    BOOL prev = _shouldDrawPlaceholder;
    _shouldDrawPlaceholder = self.placeholder && self.placeholderTextColor && self.text.length == 0;
    
    if (prev != _shouldDrawPlaceholder) {
        [self setNeedsDisplay];
    }
}


- (void)_textChanged:(NSNotification *)notification {
    [self _updateShouldDrawPlaceholder];	
}

@end
