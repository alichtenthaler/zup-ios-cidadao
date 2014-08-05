//
//  CustomButton.m
//  Zup
//
//  Created by Renato Kuroe on 25/11/13.
//  Copyright (c) 2013 Renato Kuroe. All rights reserved.
//

#import "CustomButton.h"

@implementation CustomButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)setFontSize:(float)size {
    [self.titleLabel setFont:[Utilities fontOpensSansWithSize:size]];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
