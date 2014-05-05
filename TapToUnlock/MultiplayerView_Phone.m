//
//  MultiplayerView_Phone.m
//  TapTap
//
//  Created by Hafiz on 10/5/10.
//  Copyright 2012 RTC Hubs Ltd. All rights reserved.
//

#import "MultiplayerView_Phone.h"
#import "MultiPlayViewControler.h"
#import "Global.h"




int userScore, checkTimer;
int t = 0;

extern BOOL isAcceptInvite;

int	isOpponentDisconnected = 1;

@implementation MultiplayerView_Phone
@synthesize timer, myCurrentMatch,isMatchStarted, matchPlayers;
@synthesize tapLabel, timeLabel, localScoreLabel, remoteScoreLabel;
@synthesize	remoteUserName, localUserName, controlButton;
@synthesize startTimer, statusLabel, retryButton, gamePausedAlert;
@synthesize invitation, playersArray;


//- (void)setInvitation:(GKInvite *)invitation1{
//    self.invitation = invitation1;
//    [self.invitation retain];
//}

#pragma mark Game Center Implementation

- (IBAction)multiPlayer
{
    if (isAcceptInvite){
        GKMatchmakerViewController *mmvc = [[[GKMatchmakerViewController alloc] initWithInvite:self.invitation] autorelease];
        mmvc.matchmakerDelegate = self;
        NSLog(@"Invitation: %@", self.invitation);
        [self presentModalViewController:mmvc animated:YES];
    }else{
        if (!self.myCurrentMatch){
            GKMatchRequest *request = [[[GKMatchRequest alloc] init] autorelease]; 
            request.minPlayers = 2; 
            request.maxPlayers = 2;
              if (playersArray.count>0)
                  request.playersToInvite = playersArray;
            
          
            
            GKMatchmakerViewController *mmvc = [[[GKMatchmakerViewController alloc] initWithMatchRequest:request] autorelease];
            mmvc.matchmakerDelegate = self; 
            [self presentModalViewController:mmvc animated:YES];
        }
    }
}


#pragma mark GKMatchmakerViewControllerDelegate

// The user has cancelled matchmaking
- (void)matchmakerViewControllerWasCancelled:(GKMatchmakerViewController *)viewController{
	
	[self dismissModalViewControllerAnimated:YES];
	[self.navigationController popViewControllerAnimated:YES];
}

// Matchmaking has failed with an error
- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFailWithError:(NSError *)error{
	NSLog(@"%@", [error localizedDescription]);
}

// A peer-to-peer match has been found, the game should start
- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFindMatch:(GKMatch *)match{
	
	NSLog(@"Match Found");
	statusLabel.text = @"Multiplayer Match Found";
	controlButton.hidden = YES;
	self.myCurrentMatch = [match retain];
	self.myCurrentMatch.delegate = self;
	
	[self dismissModalViewControllerAnimated:YES];
}

// Players have been found for a server-hosted game, the game should start
- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFindPlayers:(NSArray *)playerIDs{
	
    
	NSLog(@"Player Found");
	[self dismissModalViewControllerAnimated:YES];
}


- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didReceiveAcceptFromHostedPlayer:(NSString *)playerID{
    NSLog(@"player id: %@", playerID);
}

#pragma mark GKMatch	delegate

// The match received data sent from the player.
- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID{
	NSString *error; 
	NSDictionary *propertyList; 
	NSPropertyListFormat format;
	propertyList = [NSPropertyListSerialization propertyListFromData: data mutabilityOption: NSPropertyListImmutable
															  format: &format
													errorDescription: &error]; 
	if (!propertyList) {
		// Handle error
        return;
	}
    
    // Game Resume Notifier
    if ([propertyList objectForKey:@"Resume"] != nil){
        [gameView resume];
        return;
    }
    
    // Game Pause Notifier
    if ([propertyList objectForKey:@"Pause"] != nil){
        [gameView pause];
        return;
    }
    
    //Game Over Notifier
    if ([propertyList objectForKey:@"GameOver"] != nil){
        [gameView gameOver];
        [self gameOver];
        
        return;
    }
	
	if ([propertyList objectForKey:@"menu"] != nil){
		isOpponentDisconnected = 2;
		UIAlertView	*alert = [[UIAlertView alloc]
							  initWithTitle:@"Connection Error" 
							  message:@"Opponent has been disconnected from multiplayer game" delegate:self 
							  cancelButtonTitle:@"OK" 
							  otherButtonTitles:nil];
		[alert show];
		[alert release];
        return;
	}
	
	if ([propertyList objectForKey:@"score"] != nil){
		//remoteScoreLabel.text = [propertyList objectForKey:@"score"];
        gameView.remoteScoreLabel.text = [propertyList objectForKey:@"score"];
        if (gameView.timeCounter > 0 && [remoteScoreLabel.text intValue] > 0)
            gameView.localRateLabel.text = [NSString stringWithFormat:@"%.2f", (float)gameView.timeCounter/[remoteScoreLabel.text floatValue]];
        return;
	}
	
	if ([propertyList objectForKey:@"replay"] != nil){
		startTimeCounter = 0;
		if (startTimerIsStart)
			[startTimer invalidate];
		
		isLocalCall = NO;
		NSLog(@"going to play");
		[self performSelector:(NSSelectorFromString([propertyList objectForKey:@"replay"]))];
		startTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self 
													selector:(NSSelectorFromString([propertyList objectForKey:@"replay"]))
													userInfo:nil repeats:YES];
        return;
	}
	
}


// The player state changed (eg. connected or disconnected)
- (void)match:(GKMatch *)match player:(NSString *)playerID didChangeState:(GKPlayerConnectionState)state{
	
	self.matchPlayers = match.playerIDs;
	NSLog(@"didchange");
	statusLabel.text = @"Game will start soon...";
	
	if (!self.isMatchStarted && match.expectedPlayerCount == 0) {
		self.isMatchStarted = YES; // handle initial match negotiation.
	}
	
	switch (state)
	{
		case GKPlayerStateConnected: // handle a new player connection.
			NSLog(@"connected");
			multiplayerConnectionState =YES;
			break; 
		case GKPlayerStateDisconnected:
			// a player just disconnected. 
		{
			NSLog(@"disconnected");
			controlButton.hidden = NO;
			multiplayerConnectionState = NO;
			
			[timer invalidate];
			
			retryButton.hidden = YES;
			controlButton.hidden  =NO;
			UIAlertView	*alert = [[UIAlertView alloc]
								  initWithTitle:@"Error" 
								  message:@"Due to disconnection from network" delegate:nil 
								  cancelButtonTitle:@"OK" 
								  otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
			
			break;
	} 
	
	[GKPlayer loadPlayersForIdentifiers:self.matchPlayers withCompletionHandler:^(NSArray *players, NSError *error) {
		if (error != nil) {
			// Handle the error.
			NSLog(@"Error");
			UIAlertView	*alert = [[UIAlertView alloc]
								  initWithTitle:@"Network Error" 
								  message:[NSString stringWithFormat:@"%@", error] delegate:self 
								  cancelButtonTitle:@"OK" 
								  otherButtonTitles:nil];
			[alert show];
			[alert release];
		} 
		if (players != nil) 
		{
			NSLog(@"player loaded");
			
			for (GKPlayer *player in players)
			{
				remoteUserName = player.alias;
				statusLabel.text = @"Ready to play";
				startTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self 
															selector:@selector(goingToplay) 
															userInfo:nil repeats:YES];
			}
            [remoteUserName retain];
		} 
	}
	 ];
}

// The match was unable to connect with the player due to an error.
- (void)match:(GKMatch *)match connectionWithPlayerFailed:(NSString *)playerID withError:(NSError *)error{
	NSLog(@"connectionWithPlayerFailed: %@", playerID);
}


// The match was unable to be established with any players due to an error.
- (void)match:(GKMatch *)match didFailWithError:(NSError *)error{
	NSLog(@"%@", [error localizedDescription]);
}

- (BOOL)match:(GKMatch *)match shouldReinvitePlayer:(NSString *)playerID{
    return NO;
}

- (void)goingToplay{
	
	NSLog(@"going to play");
	
	startTimeCounter++;
	
	if (startTimeCounter < 4){
		startTimerIsStart = YES;
		statusLabel.text = [NSString stringWithFormat:@"Starting %d",startTimeCounter];
	}
	else if (multiplayerConnectionState){
		statusLabel.text = @"GO";
		[startTimer invalidate];
		startTimeCounter = 0;
		startTimerIsStart = NO;
		remoteScoreLabel.text = [NSString stringWithFormat:@"%@: 0", remoteUserName];
		localScoreLabel.text = [NSString stringWithFormat:@"%@: 0", [GKLocalPlayer localPlayer].alias];
		
		if (self.isMatchStarted) {
			localScore = 0;
			remoteScore = 0;
			NSLog(@"started");
			//tapLabel.hidden = NO;
			[self startGame];
		}
	}
}

- (void)secondTimePlay{
	startTimeCounter++;
	
	if (startTimeCounter < 10){
		startTimerIsStart = YES;
		if (isLocalCall)
			statusLabel.text = [NSString stringWithFormat:@"Waiting for player %d", 10 - startTimeCounter];
		else
			statusLabel.text = [NSString stringWithFormat:@"Requesting to replay %d", 10 - startTimeCounter];
	}
	else if (multiplayerConnectionState){
		[startTimer invalidate];
		startTimerIsStart = NO;
		startTimeCounter = 0;
		retryButton.hidden = NO;
		menuButton.hidden = NO;
		if (!isLocalCall)
		{
			statusLabel.text =@"No response to play again";
		}
		else{
			UIAlertView	*alert = [[UIAlertView alloc]
								  initWithTitle:@"Unwilling to play" 
								  message:@"" delegate:self 
								  cancelButtonTitle:@"OK" 
								  otherButtonTitles:nil];
			[alert show];
			[alert release];
			statusLabel.text = @"Tap Retry to Request again";
		}
	}
}


- (IBAction)startAgain
{
	if (multiplayerConnectionState){
		startTimeCounter = 0;
		statusLabel.text = [NSString stringWithFormat:@"Waiting for player %d",10 - startTimeCounter];
		t = 0;
		timeLabel.text = [NSString stringWithFormat:@"%d", t];
		NSDictionary	*dic;
		
		
		if (startTimerIsStart){
			[startTimer invalidate];
			retryButton.hidden = YES;
			menuButton.hidden = YES;
			//isLocalCall = YES;
			NSLog(@"going to play");
			dic = [NSDictionary dictionaryWithObjectsAndKeys:@"goingToplay", @"replay", nil];
			[self performSelector:@selector(goingToplay)];
			startTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self 
														selector:@selector(goingToplay) 
														userInfo:nil repeats:YES];
		}
		else {
			startTimeCounter = 0;
			retryButton.hidden = YES;
			menuButton.hidden = YES;
			isLocalCall = YES;
			dic = [NSDictionary dictionaryWithObjectsAndKeys:@"secondTimePlay", @"replay", nil];
			startTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self 
														selector:@selector(secondTimePlay) 
														userInfo:nil repeats:YES];
		}
		[self sendData:dic];
	}
	else{
		controlButton.hidden = NO;
		UIAlertView	*alert = [[UIAlertView alloc]
							  initWithTitle:@"Game Over" 
							  message:@"Due to disconnection from network" delegate:nil 
							  cancelButtonTitle:@"OK" 
							  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}



- (void)sendData:(NSDictionary*)dic
{
	NSError *error; 
	//NSDictionary	*dic = [NSDictionary dictionaryWithObjectsAndKeys:localScoreLabel.text, @"score", nil];
	
	//NSLog(@"Dic: %@", dic);
	
	NSString *errorStr = nil;
	NSData *dataRep = [NSPropertyListSerialization dataFromPropertyList: dic
																 format: NSPropertyListXMLFormat_v1_0 
													   errorDescription: &errorStr];
	if (!dataRep) { // Handle error
	}
	
	//NSData	*packet = [msg dataUsingEncoding: NSASCIIStringEncoding];
	
	[self.myCurrentMatch sendDataToAllPlayers: dataRep withDataMode: GKMatchSendDataUnreliable error:&error];
	
	if (error != nil) {
		//NSLog(@"data sent");
	}
}


- (void)gameOver{
	
	//NSLog(@"Time: %d", ++t);
	t++;
	checkTimer = t;


		[timer invalidate];
		
		retryButton.hidden = NO;
		menuButton.hidden = NO;
		tapLabel.hidden = NO;
		pauseButton.hidden = YES;
		resultLabel.hidden = NO;
		
		statusLabel.hidden = NO;
		
		statusLabel.text =@"";
		t = 0;
		
		gameView.view.userInteractionEnabled = YES;
		[gameView.view removeFromSuperview];
		
		
		if (isGamePaused){
			[gamePausedAlert dismissWithClickedButtonIndex:1 animated:NO];
			isGamePaused = NO;
		}
					
		int opponentScore = [gameView.remoteScoreLabel.text intValue];
		
		if (opponentScore > userScore){
			loose++;
			resultLabel.text = [NSString stringWithFormat:@"WIN: %d LOOSE: %d",win, loose];
		}
		else if (opponentScore < userScore){
			win++;
			resultLabel.text = [NSString stringWithFormat:@"WIN: %d LOOSE: %d", win, loose];
		}
		
		if (opponentScore == userScore){
			resultLabel.text = [NSString stringWithFormat:@"WIN: %d LOOSE: %d", win, loose];
		}
}




- (void)viewDidAppear:(BOOL)animated{
	if (!self.myCurrentMatch)
		[self multiPlayer];
}


- (IBAction)menuButtonPressed{
	
	NSDictionary	*dic = [NSDictionary dictionaryWithObjectsAndKeys:@"MENU", @"menu", nil];
	[self sendData:dic];
	
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)pauseButtonPressed{
	
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stateChange) name:@"stateChanged" object:nil];
	loose = win = 0;
	localScore = 0;
	remoteScore = 0;
	tapLabel.hidden = YES;
	startTimeCounter = 0;
	retryButton.hidden = YES;
	menuButton.hidden = YES;
	userScore = 0;
	isOpponentDisconnected = 1;
	resultLabel.hidden = YES;

    [super viewDidLoad];
}

- (void)stateChange{
	UIAlertView	*alert = [[UIAlertView alloc]
						  initWithTitle:@"Error" 
						  message:@"Due to disconnection from network" delegate:self 
						  cancelButtonTitle:@"OK" 
						  otherButtonTitles:nil];
	[alert show];
	[alert release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	
	if (buttonIndex == 0){
		
		[[NSNotificationCenter defaultCenter]removeObserver:self name:@"stateChanged" object:nil];
		
		if (isOpponentDisconnected == 1){
			NSDictionary	*dic = [NSDictionary dictionaryWithObjectsAndKeys:@"MENU", @"menu", nil];
			[self sendData:dic];
			isOpponentDisconnected = 2;
		}
		[self.navigationController popViewControllerAnimated:YES];
	}
	else 
	{
		isGamePaused = NO;
	}
}



- (void)startGame{
	pauseButton.hidden = NO;
	timeLabel.textColor = [UIColor whiteColor];
    NSString *nibName = nil;
    
    if (UI_USER_INTERFACE_IDIOM())
        nibName = @"MultiPlayViewControler_Pad";
    else
        nibName = (iSPhone5)?@"MultiPlayViewControler5": @"MultiPlayViewControler";

    
	gameView	= [[MultiPlayViewControler alloc]initWithNibName:nibName bundle:nil];
	[gameView initWithDelegate:self callbackSelector:@selector(updateData:)];
	[self.view addSubview:gameView.view];
	
	
    gameView.localPlayerName.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"localPlayer"];
    gameView.remotePlayerName.text = remoteUserName;
    
	statusLabel.hidden = YES;
	
	//[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateData) name:@"updateData" object:nil];
}


- (void)updateData:(NSString *)score{
	//NSLog(@"update Data");

    if ([score isEqualToString:@"GameOver"]){
        NSDictionary	*dic = [NSDictionary dictionaryWithObjectsAndKeys:score, @"GameOver", nil];
        NSLog(@"over");
        [self sendData:dic];
    }
    else if ([score isEqualToString:@"Pause"]){
        NSDictionary	*dic = [NSDictionary dictionaryWithObjectsAndKeys:score, @"Pause", nil];
        NSLog(@"pause");
        [self sendData:dic];
        [gameView pause];
    }
    else if ([score isEqualToString:@"Resume"]){
        NSDictionary	*dic = [NSDictionary dictionaryWithObjectsAndKeys:score, @"Resume", nil];
        NSLog(@"resume");
        [self sendData:dic];
        [gameView resume];
    }
    else if ([score isEqualToString:@"menu"]){
        NSDictionary	*dic = [NSDictionary dictionaryWithObjectsAndKeys:score, @"Resume", nil];
        NSLog(@"menu");
        [self sendData:dic];
    }
    else{
        userScore = [score intValue];
        NSDictionary	*dic = [NSDictionary dictionaryWithObjectsAndKeys:score, @"score", nil];
        [self sendData:dic];

    }
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	
	[controlButton release];
	[retryButton release];
	[localUserName release];
	[remoteUserName release];
	[statusLabel release];
	[timeLabel release];
	[tapLabel release];
	[localScoreLabel release];
	[remoteScoreLabel release];
	[matchPlayers release];
	[timer release];
	[startTimer release];
	[myCurrentMatch release];
	
    [super dealloc];
}


@end
