//
//  GameNodeController.h
//  TappingMad
//
//  Created by Hafiz on 1/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import <GameKit/GameKit.h>
#import "SinglePlayViewControler.h"
#import "Global.h"
#import "Reachability.h"
#import <QuartzCore/QuartzCore.h>



extern NSString *leaderboardIds;

@implementation SinglePlayViewControler
@synthesize dataArray = _dataArray;
@synthesize scoreLabel = _scoreLabel;
@synthesize timeLabel = _timeLabel;
@synthesize rateLabel = _rateLabel;
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

- (void)dealloc
{
    [_dataArray release];
    [_scoreLabel release];
    [_timeLabel release];
    [_rateLabel release];
    [_timer release];
    [_gameOverView release];
    [_audioPlayer release];
    [_delegate release];
    [_gamePauseView release];
    [super dealloc];
}

- (IBAction)cancelShare:(id)sender{
   
}


#pragma Mark-
#pragma Custom Methods

- (IBAction)gameCenter:(id)sender{
    if ([self isInternetAvailable]){
        NSString *leaderboard = [NSString stringWithFormat:@"%@",k_GC_LEADER_BOARD_ONE_PLAYER];
        GKLeaderboardViewController * leaderboardViewController = [[GKLeaderboardViewController alloc] init];
        [leaderboardViewController setCategory:leaderboard];
        [leaderboardViewController setLeaderboardDelegate:self];
        [self presentModalViewController:leaderboardViewController  animated:YES];
        //[leaderboardViewController release];
    }
}

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController  
{
	[self dismissModalViewControllerAnimated: YES];
}

- (IBAction)restart:(id)sender{
     [self hidePauseView];
    [self hideGameOverView];
    playerScore = 0;
    self.timeCounter = 0;
    self.isPause = NO;
    self.pauseTime = 0;
    [self initializeGame];
}


- (IBAction)menuPressed:(id)sender{
    
    if ([self.timer isValid])
        [self.timer invalidate];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)pausePressed:(id)sender{
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

- (void)hideGameOverView{
    [UIView animateWithDuration:0.3f animations:^{
        self.gameOverView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        
    }];
}


- (IBAction)resumePressed:(id)sender{
      self.isPause=FALSE;
    self.timeCounter=self.pauseTime;
    
    [self hidePauseView];
    
    [self gamePlay];
}


- (void)timeCount
{
     if(self.isPause) 
         return;
     int time = self.timeCounter++;
  self.timeLabel.text = [NSString stringWithFormat:@"%d", time];
}

- (BOOL)isInternetAvailable{
    Reachability *hostReach = [Reachability reachabilityForInternetConnection];	
	NetworkStatus netStatus = [hostReach currentReachabilityStatus];	
	if (netStatus == NotReachable){
		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Internet Error"
													   message:@"Please check your internet or connect WiFi or 3G network." 
													  delegate:nil 
											 cancelButtonTitle:@"OK" 
											 otherButtonTitles:nil];
		[alert show];
		[alert release];
		return NO;
	}
    else
        return YES;
}

#pragma Mark LockImageView Delegate
- (void)unlockedImageView:(LockImageView*)lockView{
    //NSLog(@"lock tag: %d", lockView.tag);
    AudioServicesPlaySystemSound (self.soundID);
    playerScore++;

    lockView.image = [UIImage imageNamed:@"unlock.png"];
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

- (void)gamePlay{
  
    if(self.isPause)
        return; 
    
    self.scoreLabel.text = [NSString stringWithFormat:@"%d", playerScore];
    if (self.timeCounter > 0 && playerScore > 0)
        self.rateLabel.text = [NSString stringWithFormat:@"%.2f", (float)self.timeCounter/playerScore];

    if ([self.dataArray count] > 0){
        [self generateLock];
        [self performSelector:@selector(mainThreadCall) withObject:nil afterDelay:self.timeDuration];
    }
    else{
        
        int64_t value = playerScore;
        GKScore *score = [[GKScore alloc] initWithCategory:k_GC_LEADER_BOARD_ONE_PLAYER];
        [score setValue:value];     // Submit Score
        [self performSelectorInBackground:@selector(submitScore:) withObject:score];
          
        [self.view bringSubviewToFront:self.gameOverView];
        [UIView animateWithDuration:0.5f animations:^{
            self.gameOverView.alpha = 1.0f;
        } completion:^(BOOL finished) {
            
        }];
        
        // Invalidate game loop
        [self.timer invalidate];
        
        // Save the number of play of Tap to Unlock
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSInteger numberOfPlay = [defaults integerForKey:k_PLAY_COUNTER];
        [defaults setInteger:++numberOfPlay forKey:k_PLAY_COUNTER];
        
        value = ++numberOfPlay;
        score = [[GKScore alloc] initWithCategory:k_GC_NUMBER_OF_PLAY];
        [score setValue:value];     // Submit Score
        [self performSelectorInBackground:@selector(submitScore:) withObject:score];
        
        // Save the number of Total Unlock
        NSInteger  unlockCounter = [defaults integerForKey:k_TOTAL_UNLOCK];
        [defaults setInteger:unlockCounter+playerScore forKey:k_TOTAL_UNLOCK];
        
        value = unlockCounter+playerScore;
        score = [[GKScore alloc] initWithCategory:k_GC_TOTAL_UNLOCKS];
        [score setValue:value];     // Submit Score
        [self performSelectorInBackground:@selector(submitScore:) withObject:score];
        
        // Save the Time of Play
        NSInteger  playTime = [defaults integerForKey:k_TOTAL_TIME];
        [defaults setInteger:playTime+self.timeCounter forKey:k_TOTAL_TIME];
        [defaults synchronize];
        
        value = playTime+self.timeCounter;
        score = [[GKScore alloc] initWithCategory:k_GC_PLAY_TIME];
        [score setValue:value];     // Submit Score
        [self performSelectorInBackground:@selector(submitScore:) withObject:score];
        
        // Submit each time play total score (time+unlocks)
        value = playerScore+self.timeCounter;
        score = [[GKScore alloc] initWithCategory:k_GC_TOTALS_T_N_P];
        [score setValue:value];     // Submit Score
        [self performSelectorInBackground:@selector(submitScore:) withObject:score];
        
        //NSLog(@"total unlock: %d", unlockCounter+playerScore);
        [self submitAchievementForNumberOfPlay];
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
            lockImageView.image = [UIImage imageNamed:@"lock.png"];
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
    
    // Remove All lock View
    for (LockImageView *view in [self.view subviews]){
        if ([view class] == [LockImageView class])
            [view removeFromSuperview];
    }
    // Schedule Time or Game Loop
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timeCount) userInfo:nil repeats:YES];
    
    // Remove All data from array
    [self.dataArray removeAllObjects];
    NSLog(@"initialize game");
    self.timeDuration = 0.50f;
    if (UI_USER_INTERFACE_IDIOM()){
        float xPosition = k_INITIAL_X_Pad, yPosition = k_INITIAL_Y_Pad;
        for (int i = 0; i< 5; i++){
            xPosition = k_INITIAL_X_Pad;
            for (int j = 0; j<5; j++){
                [self.dataArray addObject:NSStringFromCGRect(CGRectMake(xPosition, yPosition, 140, 140))];
                xPosition += 140+11; // Width+Gap
            }
            yPosition +=140+13; // Height+Gap
        }
    }
    else{
        int row = (iSPhone5)?5:4;
        float xPosition = k_INITIAL_X, yPosition = k_INITIAL_Y;
        for (int i = 0; i< row; i++){
            xPosition = k_INITIAL_X;
            for (int j = 0; j<3; j++){
                [self.dataArray addObject:NSStringFromCGRect(CGRectMake(xPosition, yPosition, 98, 98))];
                xPosition += 100+3; // Width+Gap
            }
            if (i == 2)
                yPosition +=103; // Height+Gap
            else
                yPosition +=103+i; // Height+Gap
            if (i == 3)
                yPosition -=3; // Height+Gap
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
    playerScore=0;
    self.pauseTime = 0;
    self.timeCounter = 0;
    self.isPause = NO;
    
    [UIView animateWithDuration:0.5f animations:^{
    } completion:^(BOOL finished) {
        
    }];

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(pausePressed:) name:@"GAME_PAUSE" object:nil];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"unlock" ofType:@"wav"];
    
    AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:path], &_soundID);      
    
    self.dataArray = [[NSMutableArray alloc]init];
    [self initializeGame];
 
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
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

#pragma Mark GC Leaderboard Methods
// Attempt to submit a score. On an error store it for a later time.
- (void)submitScore:(GKScore*)score{
    NSAutoreleasePool	*pool = [[NSAutoreleasePool alloc]init];
	
    if ([GKLocalPlayer localPlayer].authenticated) {
        if (!score.value) {
            // Unable to validate data. 
            return;
        }
        // Store the scores if there is an error. 
        [score reportScoreWithCompletionHandler:^(NSError *error){
            if (!error || (![error code] && ![error domain])) {
                // Score submitted correctly. Resubmit others
                NSLog(@"Submitted");
            } else {
                // Store score for next authentication. 
                NSLog(@"Submit Failed %@", error.localizedDescription);            
            }
        }];
    } 
	[pool release];
    
}

@end
