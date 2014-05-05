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
#import "AppDelegate.h"
#import "LockImageView.h"



@interface MultiPlayViewControler : UIViewController<LockImageViewDelegate>{
    id delegate;
    SEL selector;
}

@property (nonatomic, strong)NSMutableArray *dataArray;

// Local Player Info
@property (nonatomic, strong)IBOutlet    UILabel *localScoreLabel;
@property (nonatomic, strong)IBOutlet    UILabel *localRateLabel;
@property (nonatomic, strong)IBOutlet    UILabel *localPlayerName;


// Remote Player Info
@property (nonatomic, strong)IBOutlet    UILabel *remoteScoreLabel;
@property (nonatomic, strong)IBOutlet    UILabel *remoteRateLabel;
@property (nonatomic, strong)IBOutlet    UILabel *remotePlayerName;


@property (nonatomic, strong)IBOutlet    UILabel *timeLabel;
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

- (IBAction)menuPressed:(id)sender;
//- (IBAction)playerPressed:(id)sender;
- (void)gameOver;
- (void)pause;
- (void)resume;

- (IBAction)pausePressed:(id)sender;
- (IBAction)resumePressed:(id)sender;

- (void)initWithDelegate:(id)del callbackSelector:(SEL)sel;

@end
