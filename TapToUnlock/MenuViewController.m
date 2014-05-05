//
//  GameNodeController.h
//  TappingMad
//
//  Created by Hafiz on 1/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import "MenuViewController.h"
#import "SinglePlayViewControler.h"
#import "MultiplayerView_Phone.h"
#import "MultiPlayViewControler.h"
#import "Reachability.h"
#import "Global.h"


BOOL isAcceptInvite;
extern NSInteger   playerScore;

@implementation MenuViewController

#pragma Mark -
#pragma Button Action Methods

- (IBAction)singlePlayerPressed:(id)sender{
    SinglePlayViewControler  *gameNode;
    if (UI_USER_INTERFACE_IDIOM())
        gameNode = [[SinglePlayViewControler alloc]initWithNibName:@"SinglePlayViewControler_Pad" bundle:[NSBundle mainBundle]];
    else
        gameNode = [[SinglePlayViewControler alloc]initWithNibName:(iSPhone5)?@"SinglePlayViewControler5": @"SinglePlayViewControler" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:gameNode animated:YES];
}



- (IBAction)onlinePlayerPressed:(id)sender{
    
     isAcceptInvite = NO;
    
    NSString *nibName = nil;
    
    if (UI_USER_INTERFACE_IDIOM())
        nibName = @"MultiplayerView_Pad";
    else
        nibName = (iSPhone5)?@"MultiplayerView_Phone5":@"MultiplayerView_Phone";
    
    MultiplayerView_Phone  *gameNode = [[MultiplayerView_Phone alloc]initWithNibName:nibName bundle:[NSBundle mainBundle]];
  
    //MultiPlayViewControler  *gameNode = [[MultiPlayViewControler alloc]initWithNibName:@"MultiPlayViewControler_Pad" bundle:[NSBundle mainBundle]];
    
    [self.navigationController pushViewController:gameNode animated:YES];
}


- (IBAction)leaderBoardPressed:(id)sender{
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



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
//    if (NSClassFromString(@"ADBannerView")!=nil){
//        CGRect rect = CGRectMake(0,430,320,50);
//        iAdBanner = [[ADBannerView alloc] initWithFrame:rect];
//        [iAdBanner setDelegate:self];
//        
//        iAdBanner.requiredContentSizeIdentifiers = [NSSet setWithObject:ADBannerContentSizeIdentifierPortrait]; 
//        iAdBanner.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;		
//        [self.view addSubview:iAdBanner];
//    }
    [self initGameCenter];
}

static BOOL isGameCenterAPIAvailable()
{
    // Check for presence of GKLocalPlayer API.
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
    
    // The device must be running running iOS 4.1 or later.
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
    
    return (gcClass && osVersionSupported); 
}


-(void)initGameCenter {
    if (!isGameCenterAPIAvailable()) {
        // Game Center is not available. 
        NSLog(@"Game Center is not available.");
    } else {
        
        GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
        [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError *error) {
            NSLog(@"Game Center is available.");
            // If there is an error, do not assume local player is not authenticated.
            if (error == nil) {
                //multiPlayerButton.enabled = YES;
                NSLog(@"success: Alias: %@ ID: %@", localPlayer.alias, localPlayer.playerID);
                [[NSUserDefaults standardUserDefaults]setObject:localPlayer.alias forKey:@"localPlayer"];
            } else {
                NSLog(@"error :: %@", error);
            } 
            if (localPlayer.isAuthenticated) {
                // Enable Game Center Functionality 
                
                NSLog(@"gameCenterAuthenticationComplete");
                
                // Add block for invitation handler
                [GKMatchmaker sharedMatchmaker].inviteHandler = ^(GKInvite *acceptedInvite, NSArray *playersToInvite) {
                    // Insert application-specific code here to clean up any games in progress.
                    NSString *nibName = nil;
                    
                    if (UI_USER_INTERFACE_IDIOM())
                        nibName = @"MultiplayerView_Pad";
                    else
                        nibName = (iSPhone5)?@"MultiplayerView_Phone5":@"MultiplayerView_Phone";
                    
                    MultiplayerView_Phone  *gameNode = [[MultiplayerView_Phone alloc]initWithNibName:nibName bundle:[NSBundle mainBundle]];

                    if (acceptedInvite)
                    {
                        isAcceptInvite = YES;
                        gameNode.invitation = acceptedInvite;
                    }
                    else if (playersToInvite)
                    {
                        isAcceptInvite = NO;
                        gameNode.playersArray = playersToInvite;
                    }
                      [self.navigationController pushViewController:gameNode animated:YES];
                };
            } else {
                // User has logged out of Game Center or can not login to Game Center, your app should run 
				// without GameCenter support or user interface. 
            }
        }];
    }   
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
