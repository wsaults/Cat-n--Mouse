//
//  GKWizard.h
//  Mole It
//
//  Created by Todd Perkins on 4/25/11.
//  Copyright 2011 Wedgekase Games, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@interface GKWizard : NSObject {
    BOOL isLoggedinToGC;
    int highScore;
}


-(void)reportScore: (int)score forLeaderboard:(NSString *)leaderboard;
-(bool)isGameCenterAvailable;
-(void)authenticateLocalPlayer;
-(int)getHighScore;

@end
