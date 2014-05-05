//
//  LockImageView.m
//  Unlock
//
//  Created by Hafiz on 4/17/12.
//  Copyright (c) 2012 My Company. All rights reserved.
//

#import "LockImageView.h"

@implementation LockImageView
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma Mark Touch Delegate

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if ([self.delegate respondsToSelector:@selector(unlockedImageView:)])
        [self.delegate unlockedImageView:self];
}

@end
