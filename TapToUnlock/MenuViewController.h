//
//  GameNodeController.h
//  TappingMad
//
//  Created by Hafiz on 1/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import <MessageUI/MessageUI.h>
#import <iAd/iAd.h>
#import "AppDelegate.h"

@interface MenuViewController : UIViewController<GKLeaderboardViewControllerDelegate,MFMailComposeViewControllerDelegate,ADBannerViewDelegate> {
    ADBannerView	*iAdBanner;
    AppDelegate *delegate;
}

- (IBAction)singlePlayerPressed:(id)sender;
- (IBAction)onlinePlayerPressed:(id)sender;
- (IBAction)leaderBoardPressed:(id)sender;

- (BOOL)isInternetAvailable;

-(void)initGameCenter ;
@end
