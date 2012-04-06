//
//  GKWizard.h
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@interface GKWizard : NSObject {
    BOOL isLoggedinToGC;
    double highScore;
}


-(void)reportScore: (double)score forLeaderboard:(NSString *)leaderboard;
-(bool)isGameCenterAvailable;
-(void)authenticateLocalPlayer;
-(double)getHighScore;

@end
