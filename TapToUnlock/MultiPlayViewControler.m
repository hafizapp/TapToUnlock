//
//  GameNodeController.h
//  TappingMad
//
//  Created by Hafiz on 1/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import <GameKit/GameKit.h>
#import "MultiPlayViewControler.h"
#import "Global.h"

#define k_NUMBER_OF_LOCK 15
#define k_DIC_KEY @"POS"
#define k_INITIAL_X 21
#define k_INITIAL_Y 53

#define k_INITIAL_X_Pad 12
#define k_INITIAL_Y_Pad 135


@implementation MultiPlayViewControler

@synthesize dataArray = _dataArray;
@synthesize localRateLabel = _localRateLabel;
@synthesize timeLabel = _timeLabel;
@synthesize localPlayerName = _localPlayerName;
@synthesize localScoreLabel = _localScoreLabel;
@synthesize remoteRateLabel = _remoteRateLabel;
@synthesize remotePlayerName = _remotePlayerName;
@synthesize remoteScoreLabel = _remoteScoreLabel;
@synthesize timer = _timer;
@synthesize soundID = _soundID;
@synthesize audioPlayer = _audioPlayer;
@synthesize timeDuration = _timeDuration;
@synthesize pauseTime = _pauseTime;
@synthesize timeCounter = _timeCounter;
@synthesize isPause = _isPause;
@synthesize delegate = _delegate;
@synthesize gameOverView = _gameOverView;
@synthesize gamePauseView = _gamePauseView;


#pragma UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

    if (buttonIndex)
        [self resumePressed:nil];
    else
        [self menuPressed:nil];
}


- (void)initWithDelegate:(id)del callbackSelector:(SEL)sel{
    delegate = del;
    selector = sel;
}



- (void)gameLoop
{
    if(self.isPause) 
        return;
    int time = self.timeCounter++;
    self.timeLabel.text = [NSString stringWithFormat:@"%d", time];
}


#pragma Mark-
#pragma Custom Methods

- (IBAction)menuPressed:(id)sender{
    
    if ([self.timer isValid])
        [self.timer invalidate];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)pausePressed:(id)sender{
    [delegate performSelector:selector withObject:@"Pause"];
}

- (void)pause{
    self.isPause=TRUE;
    self.pauseTime=self.timeCounter;
    [self.view addSubview:self.gamePauseView];
    [UIView animateWithDuration:0.5f animations:^{
        self.gamePauseView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        
    }];
}


- (void)hidePauseView{
    [UIView animateWithDuration:0.3f animations:^{
        self.gamePauseView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        
    }];
}


- (IBAction)resumePressed:(id)sender{
    [UIView animateWithDuration:0.3f animations:^{
    } completion:^(BOOL finished) {
        
    }];
    [delegate performSelector:selector withObject:@"Resume"];
}

- (void)resume{
    self.isPause=FALSE;
    self.timeCounter=self.pauseTime;
    [self hidePauseView];
    
    [self gamePlay];
}


#pragma Mark LockImageView Delegate
- (void)unlockedImageView:(LockImageView*)lockView{
    //NSLog(@"lock tag: %d", lockView.tag);
    AudioServicesPlaySystemSound (self.soundID);
    playerScore++;
    
    lockView.image = [UIImage imageNamed:@"unlockm.png"];
    // Hide the Lock view if user tap it
    [UIView animateWithDuration:0.4f delay:0.5f options:UIViewAnimationCurveLinear animations:^{
        lockView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [lockView removeFromSuperview];
        [self.dataArray addObject:NSStringFromCGRect(lockView.frame)];
    }];
    // Check for Achievement and submit if it achieved
    [self submitAchievement];
}



#pragma Mark Game Play

- (void)gameOver{
    
    [UIView animateWithDuration:0.3f animations:^{
    } completion:^(BOOL finished) {
        
    }];
    
    // Invalidate game loop
    [self.timer invalidate];
    NSLog(@"Game Over");
    // Save the number of play of Tap to Unlock
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger numberOfPlay = [defaults integerForKey:k_PLAY_COUNTER];
    [defaults setInteger:++numberOfPlay forKey:k_PLAY_COUNTER];
    
    [self performSelectorInBackground:@selector(submitScore:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:++numberOfPlay],@"score",k_GC_NUMBER_OF_PLAY,@"board",nil]];
    
    // Save the number of Total Unlock
    NSInteger  unlockCounter = [defaults integerForKey:k_TOTAL_UNLOCK];
    [defaults setInteger:unlockCounter+playerScore forKey:k_TOTAL_UNLOCK];
    [defaults synchronize];
    
    [self performSelectorInBackground:@selector(submitScore:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:unlockCounter+playerScore],@"score",k_GC_TOTAL_UNLOCKS,@"board",nil]];
    
    // Save the Time of Play
    NSInteger  playTime = [defaults integerForKey:k_TOTAL_TIME];
    [defaults setInteger:playTime+self.timeCounter forKey:k_TOTAL_TIME];
    [defaults synchronize];
    
    [self performSelectorInBackground:@selector(submitScore:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:playTime+self.timeCounter],@"score",k_GC_PLAY_TIME,@"board",nil]];
    
    
    // Submit each time play total score (time+unlocks)
    [self performSelectorInBackground:@selector(submitScore:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:playerScore+self.timeCounter],@"score",k_GC_TOTALS_T_N_P,@"board",nil]];
    
    //NSLog(@"total unlock: %d", unlockCounter+playerScore);
    [self submitAchievementForNumberOfPlay];
}

- (void)gamePlay{
    
    if(self.isPause)
        return; 
    
    self.localScoreLabel.text = [NSString stringWithFormat:@"%d", playerScore];
    if (self.timeCounter > 0 && playerScore > 0)
        self.localRateLabel.text = [NSString stringWithFormat:@"%.2f", (float)self.timeCounter/playerScore];
    
    [delegate performSelector:selector withObject:self.localScoreLabel.text];
    
    if ([self.dataArray count] > 0){
        [self generateLock];
        [self performSelector:@selector(mainThreadCall) withObject:nil afterDelay:self.timeDuration];
    }
    else{
        [self.view bringSubviewToFront:self.gameOverView];
        [UIView animateWithDuration:0.5f animations:^{
            self.gameOverView.alpha = 1.0f;
        } completion:^(BOOL finished) {
            
        }];
        
        [delegate performSelector:selector withObject:@"GameOver"];

        [self gameOver];
    }
    
    if (self.timeDuration>0.18) {
        self.timeDuration = self.timeDuration-0.001;
    }
    
    //NSLog(@"%f",self.timeDuration);
    
}

- (void)mainThreadCall{
    [self performSelectorOnMainThread:@selector(gamePlay) withObject:nil waitUntilDone:NO];
}


- (void)generateLock{
    
    // Create lock for show
    if ([self.dataArray count] > 0){
        NSInteger lockCreationIndex = arc4random()%[self.dataArray count];
        LockImageView *lockImageView = [[LockImageView alloc]initWithFrame:CGRectFromString([self.dataArray objectAtIndex:lockCreationIndex])];
        lockImageView.tag = lockCreationIndex+1;
        lockImageView.userInteractionEnabled = YES;
        lockImageView.delegate = self;
        lockImageView.alpha = 0.0f;
        
        if (UI_USER_INTERFACE_IDIOM())
            lockImageView.image = [UIImage imageNamed:@"lockm.png"];
        else
            lockImageView.image = [UIImage imageNamed:@"lock-pad.png"];
        
        [self.view addSubview:lockImageView];
        
        // Animate the lock image view
        [UIView animateWithDuration:0.4f animations:^{
            lockImageView.alpha = 1.0f;
        }];
        
        // Remove created lock Index
        [self.dataArray removeObjectAtIndex:lockCreationIndex];
    }
}

- (void)initializeGame{
    
    [UIView animateWithDuration:0.3f animations:^{
    } completion:^(BOOL finished) {
    }];
    
    // Remove All lock View
    for (LockImageView *view in [self.view subviews]){
        if ([view class] == [LockImageView class])
            [view removeFromSuperview];
    }
    // Schedule Time or Game Loop
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(gameLoop) userInfo:nil repeats:YES];
    
    // Remove All data from array
    [self.dataArray removeAllObjects];
    NSLog(@"initialize game");
    self.timeDuration = 0.50f;
    if (UI_USER_INTERFACE_IDIOM()){
        float xPosition = k_INITIAL_X_Pad, yPosition = k_INITIAL_Y_Pad;
        for (int i = 0; i< 5; i++){
            xPosition = k_INITIAL_X_Pad;
            for (int j = 0; j<5; j++){
                [self.dataArray addObject:NSStringFromCGRect(CGRectMake(xPosition, yPosition, 140, 144))];
                
                if (j>=2)
                    xPosition += 140+11; // Width+Gap
                else
                    xPosition += 140+11+j; // Width+Gap
            }
             if (i == 3)
                 yPosition +=140+15; // Height+Gap
            else
                yPosition +=140+13; // Height+Gap
        }
    }
    else{
        int row = (iSPhone5)?5:4;
        float xPosition = k_INITIAL_X, yPosition = k_INITIAL_Y;
        for (int i = 0; i< row; i++){
            xPosition = k_INITIAL_X;
            for (int j = 0; j<3; j++){
                [self.dataArray addObject:NSStringFromCGRect(CGRectMake(xPosition, yPosition, 90, 90))];
                xPosition += 92+3; // Width+Gap
            }
            if (i == 2)
                yPosition +=95; // Height+Gap
            else
                yPosition +=95+i; // Height+Gap
        }
    }
    
    [self gamePlay];
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(pausePressed:) name:@"GAME_PAUSE" object:nil];

    
    playerScore = 0;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"unlock" ofType:@"wav"];
    
    AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:path], &_soundID);      
    
    self.dataArray = [[NSMutableArray alloc]init];
    [self initializeGame];
}


#pragma Mark Achievement Submitter

- (void)submitAchievementForNumberOfPlay{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSInteger numberOfPlay = [defaults integerForKey:k_PLAY_COUNTER];
    switch (numberOfPlay) {
        case 50:
            if (![defaults boolForKey:k_SUPERB]){
                [defaults setBool:YES forKey:k_SUPERB];
                [self performSelectorInBackground:@selector(reportAchievementIdentifier:) withObject:k_SUPERB];
            }
            break;
        case 75:
            if (![defaults boolForKey:k_UNLOCK_MASTER]){
                [defaults setBool:YES forKey:k_UNLOCK_MASTER];
                [self performSelectorInBackground:@selector(reportAchievementIdentifier:) withObject:k_UNLOCK_MASTER];
            }
            break;
        case 100:
            if (![defaults boolForKey:k_TAPPING_MASTER]){
                [defaults setBool:YES forKey:k_TAPPING_MASTER];
                [self performSelectorInBackground:@selector(reportAchievementIdentifier:) withObject:k_TAPPING_MASTER];
            }
            break;
        default:
            break;
    }
}

- (void)submitAchievement{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    switch (self.timeCounter) {
        case 100:
            if (![defaults boolForKey:k_AMATEUR]){
                [defaults setBool:YES forKey:k_AMATEUR];
                [self performSelectorInBackground:@selector(reportAchievementIdentifier:) withObject:k_AMATEUR];
            }
            break;
        case 200:
            if (![defaults boolForKey:k_AMAZING]){
                [defaults setBool:YES forKey:k_AMAZING];
                [self performSelectorInBackground:@selector(reportAchievementIdentifier:) withObject:k_AMAZING];
            }
            break;
        case 300:
            if (![defaults boolForKey:k_UNLOCKER]){
                [defaults setBool:YES forKey:k_UNLOCKER];
                [self performSelectorInBackground:@selector(reportAchievementIdentifier:) withObject:k_UNLOCKER];
            }
            break;
        case 400:
            if (![defaults boolForKey:k_UNLOCK_GOD]){
                [defaults setBool:YES forKey:k_UNLOCK_GOD];
                [self performSelectorInBackground:@selector(reportAchievementIdentifier:) withObject:k_UNLOCK_GOD];
            }
            break;
        case 1000:
            if (![defaults boolForKey:k_UNLOCK_GAMER]){
                [defaults setBool:YES forKey:k_UNLOCK_GAMER];
                [self performSelectorInBackground:@selector(reportAchievementIdentifier:) withObject:k_UNLOCK_GAMER];
            }
            break;
            
        default:
            break;
    }
    
    switch (playerScore) {
        case 1000:
            if (![defaults boolForKey:k_SCORER]){
                [defaults setBool:YES forKey:k_SCORER];
                [self performSelectorInBackground:@selector(reportAchievementIdentifier:) withObject:k_SCORER];
            }
            break;
        case 1500:
            if (![defaults boolForKey:k_GREAT]){
                [defaults setBool:YES forKey:k_GREAT];
                [self performSelectorInBackground:@selector(reportAchievementIdentifier:) withObject:k_GREAT];
            }
            break;
        case 2000:
            if (![defaults boolForKey:k_DASHING]){
                [defaults setBool:YES forKey:k_DASHING];
                [self performSelectorInBackground:@selector(reportAchievementIdentifier:) withObject:k_DASHING];
            }
            break;
        case 3000:
            if (![defaults boolForKey:k_TAPPER]){
                [defaults setBool:YES forKey:k_TAPPER];
                [self performSelectorInBackground:@selector(reportAchievementIdentifier:) withObject:k_TAPPER];
            }
            break;
        case 10000:
            if (![defaults boolForKey:k_UNLOCK_CHAMPION]){
                [defaults setBool:YES forKey:k_UNLOCK_CHAMPION];
                [self performSelectorInBackground:@selector(reportAchievementIdentifier:) withObject:k_UNLOCK_CHAMPION];
            }
            break;
            
        default:
            break;
    }
}

#pragma Mark Achievement Methods

- (void) reportAchievementIdentifier: (NSString*) identifier{
	
	//NSLog(@"identifier: %@", identifier);
	NSAutoreleasePool	*pool = [[NSAutoreleasePool alloc]init];
    GKAchievement *achievement = [[[GKAchievement alloc] initWithIdentifier: identifier] autorelease];
    if (achievement) {
        achievement.percentComplete = 100.0f; 
        [achievement reportAchievementWithCompletionHandler:^(NSError *error){
            if (error != nil) {
                // Retain the achievement object and try again later (notshown).
            }
        }];
    }
	[pool release];
}


#pragma Mark GC Leaderboard Methods
// Attempt to submit a score. On an error store it for a later time.
- (void)submitScore:(NSDictionary*)dictionary 
{
    //NSLog(@"dic: %@", dictionary);
    
    int64_t value = [[dictionary objectForKey:@"score"] intValue];
    GKScore * score = [[GKScore alloc] initWithCategory:[NSString stringWithFormat:@"%@",[[dictionary objectForKey:@"board"] intValue]]];
    [score setValue:value]; 
    //[score setShouldSetDefaultLeaderboard:YES];
    NSLog(@"Score: %lld", value);
    if ([GKLocalPlayer localPlayer].authenticated) {
        if (!score.value) {
            // Unable to validate data. 
            NSLog(@"returned");
            return;
        }
        
        // Store the scores if there is an error. 
        [score reportScoreWithCompletionHandler:^(NSError *error){
            if (!error || (![error code] && ![error domain])) {
                // Score submitted correctly. Resubmit others
                //[self resubmitStoredScores];
                NSLog(@"sumbitted successfully");
            } else {
                // Store score for next authentication. 
                //[self storeScore:score];
                NSLog(@"sumbission un-successfull");
            }
        }];
    }
    [score release];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
     [[NSNotificationCenter defaultCenter]removeObserver:self name:@"GAME_PAUSE" object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
