//
//  MainMenu.m
//  catnmouse
//
//  Created by William Saults on 3/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MainMenu.h"
#import "Game.h"
#import "AppDelegate.h"
#import "SimpleAudioEngine.h"
#import "Constants.h"
#import "PopUp.h"
#import "GameButton.h"
#import "CCMenuPopup.h"

@implementation MainMenu

- (id)init 
{
    if((self = [super init])) {
        // Initiliaztion code here.
        CGSize s = [[CCDirector sharedDirector] winSize];
        [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
        delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        NSString *fileName = [NSString stringWithFormat: @"%@.plist", 
                                         [delegate getCurrentSkin]];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:fileName];
        
        int fSize = 24;
        CCLabelTTF *highScore = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"High Score: %2.2f", [delegate getHighScore]] fontName:@"SF_Cartoonist_Hand_Bold.ttf" fontSize:fSize];
        highScore.anchorPoint = ccp(1,1);
        highScore.position = ccp(s.width,s.height);
        [self addChild:highScore];
        [CCMenuItemFont setFontName:@"SF_Cartoonist_Hand_Bold.ttf"];
        fSize = [CCMenuItemFont fontSize];
        [CCMenuItemFont setFontSize:48];
        
        CCMenuItemSprite *playButton = [CCMenuItemSprite itemFromNormalSprite:[GameButton buttonWithText:@"play!" isBig:YES]
                                                                selectedSprite:NULL target:self selector:@selector(playGame)];
        [CCMenuItemFont setFontSize:fSize/1.5];
        CCMenuItemSprite *leaderboardsButton = [CCMenuItemSprite itemFromNormalSprite:[GameButton buttonWithText:@"Game Center"] selectedSprite:NULL target:self selector:@selector(showLeaderboard)];
        
        [CCMenuItemFont setFontSize:fSize];
        CCMenu *menu = [CCMenu menuWithItems:leaderboardsButton, nil];
        
        [menu alignItemsHorizontallyWithPadding:20];
        menu.position = ccp(s.width/2, 20);
        [self addChild:menu];
        
        CCMenu *mainPlay = [CCMenu menuWithItems:playButton, nil];
        mainPlay.position = ccp(s.width/2,s.height/2 - s.height/3.5f);
        [self addChild:mainPlay];
        
        fileName = @"title.png";
        
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
        CCSprite *bg = [CCSprite spriteWithFile:fileName];
        bg.anchorPoint = ccp(0,0);
        [self addChild:bg z:-1];
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
    }
    return self;
}

- (void)playGame
{
    [[CCDirector sharedDirector] replaceScene:[Game scene]];
}

- (void)showLeaderboard
{
    [delegate showLeaderboard];
}

- (void)dealloc
{
    CCLOG(@"dealloc: %@", self);
    [super dealloc];
}

@end
