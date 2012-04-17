//
//  Game.h
//  catnmouse
//
//  Created by William Saults on 3/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "MyContactListener.h"

#import "AdWhirlView.h"
#import "AdWhirlDelegateProtocol.h"
#import "AppDelegate.h"
#import "RootViewController.h"

enum GameStatePP {
    kGameStatePlaying,
    kGameStatePaused
};

@class AppDelegate;

@interface Game : CCLayer <CCStandardTouchDelegate, AdWhirlDelegate>{
    
    // Add inside @interface
    RootViewController *viewController;
    AdWhirlView *adWhirlView;
    
    enum GameStatePP _state;
    
    CCArray *bonus, *cats;
    CCLabelBMFont *scoreLabel;
    AppDelegate *delegate;
    CCMenuItemSprite *pauseButton;
    CCLabelTTF *pause;
    
    double gameTime;
    CGSize s;
    bool isPaused;
    double score;
    
    b2Vec2 gravity;
    b2World *_world;
    b2Body *_groundBody;
    b2Fixture *_bottomFixture;
    
    int numberOfCats;
    bool isThereCheese;
    int r;
    
    // Cat 1
    b2FixtureDef cat1ShapeDef;
    b2Fixture *_cat1Fixture;
    
    // Cat 2
    b2FixtureDef cat2ShapeDef;
    b2Fixture *_cat2Fixture;
    
    // Cat 3
    b2FixtureDef cat3ShapeDef;
    b2Fixture *_cat3Fixture;
    
    // Cat 4
    b2FixtureDef cat4ShapeDef;
    b2Fixture *_cat4Fixture;
    
    // Cat 5
    b2FixtureDef cat5ShapeDef;
    b2Fixture *_cat5Fixture;
    
    // Mouse
    b2Body *_mouseBody;
    b2Fixture *_mouseFixture;
    
    // Cheese 10
    b2FixtureDef cheese10ShapeDef;
    b2Fixture *_cheese10Fixture;
    
    // Cheese 5
    b2FixtureDef cheese5ShapeDef;
    b2Fixture *_cheese5Fixture;
    
    b2MouseJoint *_mouseJoint;
    
    MyContactListener *_contactListener;
    
    CCLabelTTF *highScore;
    
}

// Add after @interface
@property(nonatomic,retain) AdWhirlView *adWhirlView;
@property(nonatomic) enum GameStatePP state;

-(void)pauseGame;
-(void)resumeGame;
-(void)startGame;
-(void)initializeGame;
-(void)mainMenu;
-(void)gameOver;
-(void)playAgain;

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
