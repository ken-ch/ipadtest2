//
//  leftview.m
//  ipadtest2
//
//  Created by kench on 2018/6/26.
//  Copyright © 2018年 kench. All rights reserved.
//

#import "leftview.h"

@implementation leftview

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat X = 5;
        CGFloat Y = 50;
        CGFloat W = kenscreenheight *0.3 - X;
        CGFloat H =kenscreenwidth - Y -5;
        
        
        UIView *topleftview = [[UIView alloc]initWithFrame:CGRectMake(X, 5, W, 40)];
        [self addSubview:topleftview];
        topleftview.backgroundColor = [UIColor whiteColor];
        topleftview.layer.cornerRadius = 10;
        UILabel *topleftlbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, W, 40)];
        topleftlbl.text = @"功能选择区";
        topleftlbl.textAlignment = NSTextAlignmentCenter;
        topleftlbl.font = [UIFont systemFontOfSize:30];
        [topleftview addSubview:topleftlbl];
        
      //  [self setviewalpha:topleftview];
        
        
        UIView *leftview = [[UIView alloc]initWithFrame:CGRectMake(X, Y, W, H)];
       [self addSubview:leftview];
        leftview.backgroundColor = [UIColor whiteColor];
        leftview.layer.cornerRadius = 10;
     //   self.optionview = leftview;
   //     [self setviewalpha:leftview];
        
        
        
        [self sendSubviewToBack:topleftlbl];
        [self sendSubviewToBack:topleftview];
    }
    return self;
}


@end
