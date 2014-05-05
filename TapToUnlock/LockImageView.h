//
//  LockImageView.h
//  Unlock
//
//  Created by Hafiz on 4/17/12.
//  Copyright (c) 2012 My Company. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol LockImageViewDelegate;

@interface LockImageView : UIImageView

@property(nonatomic, strong)id<LockImageViewDelegate> delegate;
@end

@protocol LockImageViewDelegate <NSObject>

- (void)unlockedImageView:(LockImageView*)lockView;

@end
