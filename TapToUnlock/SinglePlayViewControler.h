//
//  GameNodeController.h
//  TappingMad
//
//  Created by Hafiz on 1/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVAudioPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <MessageUI/MessageUI.h>
#import "AppDelegate.h"

#import "LockImageView.h"
#import <GameKit/GameKit.h>


#define k_NUMBER_OF_LOCK 15
#define k_DIC_KEY @"POS"
#define k_INITIAL_X 8
#define k_INITIAL_Y 55

#define k_INITIAL_X_Pad 12
#define k_INITIAL_Y_Pad 126



@interface SinglePlayViewControler : UIViewController<UIActionSheetDelegate,MFMailComposeViewControllerDelegate, LockImageViewDelegate, GKLeaderboardViewControllerDelegate>

@property (nonatomic, strong)NSMutableArray *dataArray;
@property (nonatomic, strong)IBOutlet    UILabel *scoreLabel;
@property (nonatomic, strong)IBOutlet    UILabel *timeLabel;
@property (nonatomic, strong)IBOutlet    UILabel *rateLabel;
@property (nonatomic, strong)NSTimer *timer;
@property (nonatomic) SystemSoundID soundID;
@property (nonatomic, strong)IBOutlet UIView *gameOverView;
@property (nonatomic, strong)IBOutlet UIView *gamePauseView;
@property (nonatomic, strong)AppDelegate *delegate;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic)CGFloat timeDuration;
@property (nonatomic)int pauseTime;
@property (nonatomic)int timeCounter;
@property (nonatomic)bool isPause;

@end
