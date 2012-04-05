//
//  GKWizard.m
//  Mole It
//
//  Created by Todd Perkins on 4/25/11.
//  Copyright 2011 Wedgekase Games, LLC. All rights reserved.
//

#import "GKWizard.h"
#import "Constants.h"
#import "cocos2d.h"

@implementation GKWizard

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        highScore = [[NSUserDefaults standardUserDefaults] integerForKey:kHighScoreKey];
        [self authenticateLocalPlayer];
    }
    
    return self;
}

-(void)reportScore: (int)score forLeaderboard:(NSString *)leaderboard
{
    if (![self isGameCenterAvailable]) {
        return;
    }
    GKScore *scoreReporter = [[[GKScore alloc] initWithCategory:leaderboard] autorelease];
    if (scoreReporter.value < score) {
        scoreReporter.value = score;
    }
    else
    {
        return;
    }
    
	
    [scoreReporter reportScoreWithCompletionHandler:^(NSError *error) {
		if (error != nil)
		{
            // handle the reporting error
        }
    }];
}

- (void) authenticateLocalPlayer
{
	if (![self isGameCenterAvailable]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Feature Not Available" message:@"Game Center features require supported devices/operating systems." delegate:NULL cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
    [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError *error) {
		if (error == nil)
		{
			// Insert code here to handle a successful authentication.
			
			isLoggedinToGC = YES;
		}
		else
		{
			// Your application can process the error parameter to report the error to the player.
			//NSLog(@"error logging in");
		}
	}];
}

- (void) reportScore: (int64_t) score forCategory: (NSString*) category
{
    
}

-(bool) isGameCenterAvailable
{
    // Check for presence of GKLocalPlayer API.
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
	
    // The device must be running running iOS 4.1 or later.
    bool isIPAD = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
    NSString *reqSysVer = (isIPAD) ? @"4.2" : @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
	
    return (gcClass && osVersionSupported);
}

-(int)getHighScore
{
    return highScore;
}

- (void)dealloc
{
    [super dealloc];
}

@end
