//
//  MultiplayerView_Phone.h
//  TapTap
//
//  Created by Hafiz on 10/5/10.
//  Copyright 2012 RTC Hubs Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import	"MultiPlayViewControler.h"


@interface MultiplayerView_Phone : UIViewController <GKMatchmakerViewControllerDelegate, GKMatchDelegate>{
	
	
	NSTimer	*timer, *startTimer;
	GKMatch	*myCurrentMatch;
	BOOL	isMatchStarted;
	NSArray	*matchPlayers;
	IBOutlet	UILabel *timeLabel, *localScoreLabel, *remoteScoreLabel, *resultLabel;
	IBOutlet	UIImageView	*resultBG;
	int localScore, remoteScore;
	NSString		*localUserName, *remoteUserName;
	IBOutlet	UIButton	*controlButton, *retryButton, *menuButton, *pauseButton;
	
	IBOutlet	UILabel	*statusLabel;
	
	BOOL multiplayerConnectionState, startTimerIsStart, isLocalCall, isGamePaused;
	
	int startTimeCounter;
	MultiPlayViewControler	*gameView;
	int loose, win;
	UIAlertView	*gamePausedAlert;
    GKInvite *invitation;
	NSArray *playersArray;
}
@property (nonatomic, retain)NSArray *playersArray;
@property (nonatomic, retain)GKInvite *invitation;
@property (nonatomic, retain)UIAlertView	*gamePausedAlert;
@property (nonatomic, retain)UIButton	*controlButton;
@property (nonatomic, retain)UIButton	*retryButton;
@property (nonatomic, retain)NSString *	localUserName;
@property (nonatomic, retain)NSString *	remoteUserName	;
@property (nonatomic, retain)UILabel	*timeLabel;
@property (nonatomic, retain)UILabel	*statusLabel;
@property (nonatomic, retain)UILabel	*tapLabel;
@property (nonatomic, retain)UILabel	*localScoreLabel;
@property (nonatomic, retain)UILabel	*remoteScoreLabel;
@property (nonatomic, retain)NSArray	*matchPlayers;
@property(nonatomic, retain)NSTimer	*timer;
@property(nonatomic, retain)NSTimer	*startTimer;
@property (nonatomic)BOOL	isMatchStarted;
@property (nonatomic, retain)GKMatch	*myCurrentMatch;

- (void)sendData:(NSDictionary*)score;
- (IBAction)startAgain;
- (IBAction)multiPlayer;
- (void)startGame;
- (IBAction)menuButtonPressed;
- (IBAction)pauseButtonPressed;


@end
