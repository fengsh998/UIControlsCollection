//
//  QBTextView.h
//  QianbaoIM
//
//  Created by fengsh on 30/4/15.
//  Copyright (c) 2015年 qianbao.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QBTextView : UITextView
/**
 *  默认 nil
 */
@property (nonatomic, strong) NSString *placeholder;
/**
 *  [UIColor lightGrayColor]`.
 */
@property (nonatomic, strong) UIColor *placeholderTextColor;
@end
