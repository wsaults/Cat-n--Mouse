//
//  Game.m
//  catnmouse
//
//  Created by William Saults on 3/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Game.h"
#import "MainMenu.h"
#import "AppDelegate.h"
#import "SimpleAudioEngine.h"
#import "Constants.h"
#import "PopUp.h"
#import "GameButton.h"
#import "CCMenuPopup.h"

#define PTM_RATIO 32.0

@implementation Game

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	Game *layer = [Game node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (id)init
{
    if((self = [super init])) {
        
    }
    return self;
}

- (void)initializeGame
{
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [[CCDirector sharedDirector] resume];
    s = [[CCDirector sharedDirector] winSize];
    
    NSString *fileName = [NSString stringWithFormat:@"%@.plist", [delegate getCurrentSkin]];
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:fileName];
    
    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
    CCSprite *bg = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%@_bg.png", [delegate getCurrentSkin]]];
    bg.anchorPoint = ccp(0,0);
    [self addChild:bg z:-1];
    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
    
    pauseButton = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"pause_button.png"] selectedSprite:NULL target:self selector:@selector(pauseGame)];
    CCMenu *menu = [CCMenu menuWithItems:pauseButton, nil];
    pauseButton.position = ccp(s.width/2 - pauseButton.contentSize.width/2, (-s.height/2) + pauseButton.contentSize.height/2);
    [self addChild:menu z:100];
    
    [self startGame];
}

- (void)startGame
{    
//    [SimpleAudioEngine sharedEngine] playBackgroundMusic:@".caf"];
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    // Create a world
    b2Vec2 gravity = b2Vec2(0.0f, 0.0f);
    bool doSleep = true;
    _world = new b2World(gravity, doSleep);
    
    // Create edges around the entire screen
    b2BodyDef groundBodyDef;
    groundBodyDef.position.Set(0,0);
    _groundBody = _world->CreateBody(&groundBodyDef);
    b2PolygonShape groundBox;
    b2FixtureDef groundBoxDef;
    groundBoxDef.shape = &groundBox;
    groundBox.SetAsEdge(b2Vec2(0,0), b2Vec2(winSize.width/PTM_RATIO, 0));
    _bottomFixture = _groundBody->CreateFixture(&groundBoxDef);
    groundBox.SetAsEdge(b2Vec2(0,0), b2Vec2(0, winSize.height/PTM_RATIO));
    _groundBody->CreateFixture(&groundBoxDef);
    groundBox.SetAsEdge(b2Vec2(0, winSize.height/PTM_RATIO), b2Vec2(winSize.width/PTM_RATIO, 
                                                                    winSize.height/PTM_RATIO));
    _groundBody->CreateFixture(&groundBoxDef);
    groundBox.SetAsEdge(b2Vec2(winSize.width/PTM_RATIO, winSize.height/PTM_RATIO), 
                        b2Vec2(winSize.width/PTM_RATIO, 0));
    _groundBody->CreateFixture(&groundBoxDef);
    
    // Create sprite and add it to the layer
    CCSprite *ball = [CCSprite spriteWithFile:@"Ball.png" 
                                         rect:CGRectMake(0, 0, 52, 52)];
    
    ball.position = ccp(100, 100);
    ball.tag = 1;
    [self addChild:ball];
    
    // Create ball body 
    b2BodyDef ballBodyDef;
    ballBodyDef.type = b2_dynamicBody;
    ballBodyDef.position.Set(100/PTM_RATIO, 100/PTM_RATIO);
    ballBodyDef.userData = ball;
    b2Body * ballBody = _world->CreateBody(&ballBodyDef);
    
    // Create circle shape
    b2CircleShape circle;
    circle.m_radius = 26.0/PTM_RATIO;
    
    // Create shape definition and add to body
    b2FixtureDef ballShapeDef;
    ballShapeDef.shape = &circle;
    ballShapeDef.density = 1.0f;
    ballShapeDef.friction = 0.f;
    ballShapeDef.restitution = 1.0f;
    _ballFixture = ballBody->CreateFixture(&ballShapeDef);
    
    b2Vec2 force = b2Vec2(10, 10);
    ballBody->ApplyLinearImpulse(force, ballBodyDef.position);
    
    
    
    // Create mouse and add it to the layer
    CCSprite *mouse = [CCSprite spriteWithFile:@"Ball.png" rect:CGRectMake(0, 0, 52, 52)];
    mouse.position = ccp(winSize.width/2, 50);
    [self addChild:mouse];
    
    // Create paddle body
    b2BodyDef mouseBodyDef;
    mouseBodyDef.type = b2_dynamicBody;
    mouseBodyDef.position.Set(winSize.width/2/PTM_RATIO, 50/PTM_RATIO);
    mouseBodyDef.userData = mouse;
    _mouseBody = _world->CreateBody(&mouseBodyDef);
    
    // Create paddle shape
    b2CircleShape mouseShape;
    mouseShape.m_radius = 26.0/PTM_RATIO;
    
    // Create shape definition and add to body
    b2FixtureDef mouseShapeDef;
    mouseShapeDef.shape = &mouseShape;
    mouseShapeDef.density = 10.0f;
    mouseShapeDef.friction = 0.4f;
    mouseShapeDef.restitution = 0.1f;
    _mouseFixture = _mouseBody->CreateFixture(&mouseShapeDef);
    
    // Create contact listener
    _contactListener = new MyContactListener();
    _world->SetContactListener(_contactListener);
    
    [self schedule:@selector(tick:)];
}

- (void)tick:(ccTime)dt
{
    _world->Step(dt, 10, 10);    
    for(b2Body *b = _world->GetBodyList(); b; b=b->GetNext()) {    
        if (b->GetUserData() != NULL) {
            CCSprite *sprite = (CCSprite *)b->GetUserData();                        
            sprite.position = ccp(b->GetPosition().x * PTM_RATIO,
                                  b->GetPosition().y * PTM_RATIO);
            sprite.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
            
            if (sprite.tag == 1) {
                static int maxSpeed = 10;
                
                b2Vec2 velocity = b->GetLinearVelocity();
                float32 speed = velocity.Length();
                
                if (speed > maxSpeed) {
                    b->SetLinearDamping(0.5);
                } else if (speed < maxSpeed) {
                    b->SetLinearDamping(0.0);
                }
                
            }
        }
    }
    
    std::vector<MyContact>::iterator pos;
    for(pos = _contactListener->_contacts.begin(); 
        pos != _contactListener->_contacts.end(); ++pos) {
        MyContact contact = *pos;
        
        if ((contact.fixtureA == _mouseFixture && contact.fixtureB == _ballFixture) ||
            (contact.fixtureA == _ballFixture && contact.fixtureB == _mouseFixture)) {
            CCLOG(@"Cat got the mouse!");
            [self gameOver];
        }
    }
    
    //timeElapsed += dt;
    
    // If so much time passes do something...
    // If timeElapsed >= timeToSpeedUpCats
    // [self speedUpCats];
    // timeElapsed = 0;
    
    // eg:
    //    if (timeElapsed >= timeBetweenMoles)
    //    {
    //        [self chooseWhichMoleToMake];
    //        timeElapsed = 0;
    //    }
    
}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (isPaused) {
        return;
    }
    
    if (_mouseJoint != NULL) return;
    
    UITouch *myTouch = [touches anyObject];
    CGPoint location = [myTouch locationInView:[myTouch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    b2Vec2 locationWorld = b2Vec2(location.x/PTM_RATIO, location.y/PTM_RATIO);
    
    if (_mouseFixture->TestPoint(locationWorld)) {
        b2MouseJointDef md;
        md.bodyA = _groundBody;
        md.bodyB = _mouseBody;
        md.target = locationWorld;
        md.collideConnected = true;
        md.maxForce = 1000.0f * _mouseBody->GetMass();
        
        _mouseJoint = (b2MouseJoint *)_world->CreateJoint(&md);
        _mouseBody->SetAwake(true);
    }
    
    for (UITouch *touch in [event allTouches]) {
        // Touches a bonus point
#warning See Chapter 3. Moleit Handling Touches in the game
//        for (Bonus *bonus in bonus) {
//            CGPoint location = [touch locationInView:touch.view];
//            location = [[CCDirector sharedDirector] convertToGL:location];
//            if (CGRectContainsPoint([bonus boundingBox, location)) {
//                if(![bonus getIsUp])
//                {
//                    continue;
//                }
//                [bonus wasTapped];
//            }
//        }
    }
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (_mouseJoint == NULL) return;
    
    UITouch *myTouch = [touches anyObject];
    CGPoint location = [myTouch locationInView:[myTouch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    b2Vec2 locationWorld = b2Vec2(location.x/PTM_RATIO, location.y/PTM_RATIO);
    
    _mouseJoint->SetTarget(locationWorld);
    
}

-(void)ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (_mouseJoint) {
        _world->DestroyJoint(_mouseJoint);
        _mouseJoint = NULL;
    }
    
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_mouseJoint) {
        _world->DestroyJoint(_mouseJoint);
        _mouseJoint = NULL;
    }  
}


-(void)didScore
{
    
}

- (void)gameOver
{
    //    for (Cat *c in cats) {
    //        [c stopAllActions];
    //        [c unscheduleAllSelectors];
    //    }
    
    [delegate finishedWithScore:score];
    [self unscheduleAllSelectors];
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    
    CCMenuItemSprite *playAgainButton = [CCMenuItemSprite itemFromNormalSprite:[GameButton buttonWithText:@"play again"] selectedSprite:NULL target:self selector:@selector(playAgain)];
    CCMenuItemSprite *mainButton = [CCMenuItemSprite itemFromNormalSprite:[GameButton buttonWithText:@"main menu"] selectedSprite:NULL target:self selector:@selector(mainMenu)];
    
    CCMenuPopup *menu = [CCMenuPopup menuWithItems:playAgainButton,mainButton, nil];
    [menu alignItemsHorizontallyWithPadding:10];
    PopUp *pop = [PopUp popUpWithTitle:@"-game over-" description:@"" sprite:menu];
    [self addChild:pop z:1000];
    
}

- (void)pauseGame
{
    if (isPaused) {
        return;
    }
    CCMenuItemSprite *resumeButton = [CCMenuItemSprite itemFromNormalSprite:[GameButton buttonWithText:@"resume"] selectedSprite:NULL target:self selector:@selector(resumeGame)];
    CCMenuItemSprite *mainButton = [CCMenuItemSprite itemFromNormalSprite:[GameButton buttonWithText:@"main menu"] selectedSprite:NULL target:self selector:@selector(mainMenu)];
    
    CCMenuPopup *menu = [CCMenuPopup menuWithItems:resumeButton,mainButton, nil];
    [menu alignItemsHorizontallyWithPadding:10];
    PopUp *pop = [PopUp popUpWithTitle:@"-pause-" description:@"" sprite:menu];
    [self addChild:pop z:1000];
    pauseButton.visible = NO;
    
//    for (Cat *c in [self cats]) {
//        [c stopEarly];
//    }
    
    [self unschedule:@selector(tick:)];
    [[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
    isPaused = YES;
}

- (void)resumeGame
{
    pauseButton.visible = YES;
    
    [self schedule:@selector(tick:)];
    [[SimpleAudioEngine sharedEngine] resumeBackgroundMusic];
    isPaused = NO;

}

- (void)mainMenu
{
    [[CCDirector sharedDirector] resume];
    [[CCDirector sharedDirector] replaceScene:[MainMenu node]];
}

-(void)playAgain
{
    [[CCDirector sharedDirector] resume];
    [[CCDirector sharedDirector] replaceScene:[[self class] node]];
}

- (void)onEnterTransitionDidFinish
{
    [[CCTouchDispatcher sharedDispatcher] addStandardDelegate:self priority:0];
    [[[CCDirector sharedDirector] openGLView] setMultipleTouchEnabled:YES];
    [self initializeGame];
}

- (void)onExit
{
    [[CCTouchDispatcher sharedDispatcher] removeAllDelegates];
}

- (void)dealloc
{
    delete _world;
    _groundBody = NULL;
    delete _contactListener;
    CCLOG(@"dealloc: %@", self);
    [super dealloc];
}

@end