//
//  AppDelegate.h
//  catnmouse
//
//  Created by William Saults on 3/23/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate, UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
    BOOL hasPlayedBefore;
    NSString *currentSkin;
    int timesPlayed,currentAction;
}

@property (nonatomic, retain) UIWindow *window;

- (void)finishedWithScore:(int)score;
- (int)getHighScore;
- (void)pause;
- (void)resume;
- (BOOL)isGameScene;
- (NSString *)getCurrentSkin;
- (UIViewController *)getViewController;

@end
