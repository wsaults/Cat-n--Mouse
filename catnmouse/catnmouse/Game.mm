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
#define NUMBER_OF_CATS 0

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
//    CCSprite *bg = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%@_bg.png", [delegate getCurrentSkin]]];
    
    CCSprite *bg = [CCSprite spriteWithFile:[NSString stringWithFormat:@"cat_bg.png"]];
    
    bg.anchorPoint = ccp(0,0);
    [self addChild:bg z:-1];
    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
    
    // Pause Button
    pauseButton = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"pause_button.png"] selectedSprite:NULL target:self selector:@selector(pauseGame)];
    CCMenu *menu = [CCMenu menuWithItems:pauseButton, nil];
    pauseButton.position = ccp(s.width/2 - pauseButton.contentSize.width/2, (-s.height/2) + pauseButton.contentSize.height*1.5);
    [self addChild:menu z:100];
    
    int fSize = 28;
    CCLabelTTF *pause = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"ll"] fontName:@"SF_Cartoonist_Hand_Bold.ttf" fontSize:fSize];
    pause.position = ccp(s.width/1.085, s.height/6.7);
    [self addChild:pause z:101];
    
    [self startGame];
}

- (void)startGame
{    
//    [SimpleAudioEngine sharedEngine] playBackgroundMusic:@".caf"];
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    // Create a world
    gravity = b2Vec2(0.0f, 0.0f);
    bool doSleep = true;
    _world = new b2World(gravity, doSleep);
    
    // Create edges around the entire screen
    b2BodyDef groundBodyDef;
    
    // Right bounds
    groundBodyDef.position.Set(0,0);
    _groundBody = _world->CreateBody(&groundBodyDef);
    b2PolygonShape groundBox;
    b2FixtureDef groundBoxDef;
    groundBoxDef.shape = &groundBox;
    
    // Bottom bounds
    groundBox.SetAsEdge(b2Vec2(0,0), b2Vec2(winSize.width/PTM_RATIO,0));
    _bottomFixture = _groundBody->CreateFixture(&groundBoxDef);
    
    // Left bounds
    groundBox.SetAsEdge(b2Vec2(0,0), b2Vec2(0, winSize.height/PTM_RATIO));
    _groundBody->CreateFixture(&groundBoxDef);
    
    // Top bounds
    groundBox.SetAsEdge(b2Vec2(0, winSize.height/PTM_RATIO), b2Vec2(winSize.width/PTM_RATIO, 
                                                                    winSize.height/PTM_RATIO));
    _groundBody->CreateFixture(&groundBoxDef);
    groundBox.SetAsEdge(b2Vec2(winSize.width/PTM_RATIO, winSize.height/PTM_RATIO), 
                        b2Vec2(winSize.width/PTM_RATIO, 0));
    _groundBody->CreateFixture(&groundBoxDef);
    
    // Body for ads
    b2BodyDef bd;
    bd.position.Set(0, 0);
    b2Body* body = _world->CreateBody(&bd);
    
    b2PolygonShape shape;
    shape.SetAsBox(winSize.width/PTM_RATIO, 1.5);  // The box's size
    
    b2FixtureDef fd;
    fd.shape = &shape;
    fd.density = 0.1f;
    body->CreateFixture(&fd);
    
    // Create sprite and add it to the layer
    CCSprite *cat1 = [CCSprite spriteWithFile:@"Ball.png" 
                                         rect:CGRectMake(0, 0, 52, 52)];
    
    cat1.position = ccp(100, 100);
    cat1.tag = 1;
    [self addChild:cat1];
    
    // Create ball body 
    b2BodyDef cat1BodyDef;
    cat1BodyDef.type = b2_dynamicBody;
    cat1BodyDef.position.Set(100/PTM_RATIO, 100/PTM_RATIO);
    cat1BodyDef.userData = cat1;
    b2Body * cat1Body = _world->CreateBody(&cat1BodyDef);
    
    // Create circle shape
    b2CircleShape circle;
    circle.m_radius = 26.0/PTM_RATIO;
    
    // Create shape definition and add to body
    cat1ShapeDef.shape = &circle;
    cat1ShapeDef.density = 1.0f;
    cat1ShapeDef.friction = 0.001f;
    cat1ShapeDef.restitution = 1.0f;
    _cat1Fixture = cat1Body->CreateFixture(&cat1ShapeDef);
    
    b2Vec2 force = b2Vec2(10, 10);
    cat1Body->ApplyLinearImpulse(force, cat1BodyDef.position);
    // end cat1
    
    // Cat 2
    // Create sprite and add it to the layer
    CCSprite *cat2 = [CCSprite spriteWithFile:@"Ball.png" 
                                         rect:CGRectMake(0, 0, 52, 52)];
    cat2.position = ccp(300, 100);
    cat2.tag = 2;
    [self addChild:cat2];
    
    // Create cat2 body 
    b2BodyDef cat2BodyDef;
    cat2BodyDef.type = b2_dynamicBody;
    cat2BodyDef.position.Set(300/PTM_RATIO, 100/PTM_RATIO);
    cat2BodyDef.userData = cat2;
    b2Body * cat2Body = _world->CreateBody(&cat2BodyDef);
    
    // Create shape definition and add to body
    cat2ShapeDef.shape = &circle;
    cat2ShapeDef.density = 1.0f;
    cat2ShapeDef.friction = 0.001f;
    cat2ShapeDef.restitution = 1.0f;
    _cat2Fixture = cat2Body->CreateFixture(&cat2ShapeDef);
    
    cat2Body->ApplyLinearImpulse(force, cat2BodyDef.position);
    // end cat 2
    numberOfCats = 2;
    
    // Create mouse and add it to the layer
    CCSprite *mouse = [CCSprite spriteWithFile:@"Ball.png" rect:CGRectMake(0, 0, 52, 52)];
    mouse.position = ccp(winSize.width/2, winSize.height/3);
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
    mouseShapeDef.friction = 0.f;
    mouseShapeDef.restitution = 0.001f;
    _mouseFixture = _mouseBody->CreateFixture(&mouseShapeDef);
    
    // Create contact listener
    _contactListener = new MyContactListener();
    _world->SetContactListener(_contactListener);
    
    int fSize = 24;
    gameTime = 0.00f;
    highScore = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%f", gameTime] fontName:@"SF_Cartoonist_Hand_Bold.ttf" fontSize:fSize];
    highScore.anchorPoint = ccp(1,1);
    highScore.position = ccp(s.width,s.height);
    [self addChild:highScore];
    
    [self schedule:@selector(tick:)];
}

- (void)tick:(ccTime)dt
{    
    if (!isPaused) {
        gameTime += dt;
        score = gameTime;
        NSString *string = [[NSString alloc] initWithFormat:@"%2.2f",gameTime];
        [highScore setString:string];
    
        if (gameTime > 3.0f && numberOfCats == 2) {
            // Create circle shape
            b2CircleShape circle;
            circle.m_radius = 26.0/PTM_RATIO;
            
            b2Vec2 force = b2Vec2(10, 10);
            
            // Cat 3
            // Create sprite and add it to the layer
            CCSprite *cat3 = [CCSprite spriteWithFile:@"Ball.png" 
                                                 rect:CGRectMake(0, 0, 52, 52)];
            cat3.position = ccp(50, 50);
            cat3.tag = 3;
            [self addChild:cat3];
            
            // Create cat3 body 
            b2BodyDef cat3BodyDef;
            cat3BodyDef.type = b2_dynamicBody;
            cat3BodyDef.position.Set(50/PTM_RATIO, 50/PTM_RATIO);
            cat3BodyDef.userData = cat3;
            b2Body * cat3Body = _world->CreateBody(&cat3BodyDef);
            
            // Create shape definition and add to body
            cat3ShapeDef.shape = &circle;
            cat3ShapeDef.density = 1.0f;
            cat3ShapeDef.friction = 0.001f;
            cat3ShapeDef.restitution = 1.0f;
            _cat3Fixture = cat3Body->CreateFixture(&cat3ShapeDef);
            
            cat3Body->ApplyLinearImpulse(force, cat3BodyDef.position);
            // end cat 3
            numberOfCats++;
        }
        
        if (gameTime > 8.0f && numberOfCats == 3) {
            // Create circle shape
            b2CircleShape circle;
            circle.m_radius = 26.0/PTM_RATIO;
            
            b2Vec2 force = b2Vec2(10, 10);
            
            // Cat 4
            // Create sprite and add it to the layer
            CCSprite *cat4 = [CCSprite spriteWithFile:@"Ball.png" 
                                                 rect:CGRectMake(0, 0, 52, 52)];
            cat4.position = ccp(50, 50);
            cat4.tag = 4;
            [self addChild:cat4];
            
            // Create cat4 body 
            b2BodyDef cat4BodyDef;
            cat4BodyDef.type = b2_dynamicBody;
            cat4BodyDef.position.Set(50/PTM_RATIO, 50/PTM_RATIO);
            cat4BodyDef.userData = cat4;
            b2Body * cat4Body = _world->CreateBody(&cat4BodyDef);
            
            // Create shape definition and add to body
            cat4ShapeDef.shape = &circle;
            cat4ShapeDef.density = 1.0f;
            cat4ShapeDef.friction = 0.001f;
            cat4ShapeDef.restitution = 1.0f;
            _cat4Fixture = cat4Body->CreateFixture(&cat4ShapeDef);
            
            cat4Body->ApplyLinearImpulse(force, cat4BodyDef.position);
            // end cat 4
            numberOfCats++;
        }
        
        if (gameTime > 15.0f && numberOfCats == 4) {
            // Create circle shape
            b2CircleShape circle;
            circle.m_radius = 26.0/PTM_RATIO;
            
            b2Vec2 force = b2Vec2(10, 10);
            
            // Cat 5
            // Create sprite and add it to the layer
            CCSprite *cat5 = [CCSprite spriteWithFile:@"Ball.png" 
                                                 rect:CGRectMake(0, 0, 52, 52)];
            cat5.position = ccp(100, 100);
            cat5.tag = 5;
            [self addChild:cat5];
            
            // Create cat5 body 
            b2BodyDef cat5BodyDef;
            cat5BodyDef.type = b2_dynamicBody;
            cat5BodyDef.position.Set(100/PTM_RATIO, 100/PTM_RATIO);
            cat5BodyDef.userData = cat5;
            b2Body * cat5Body = _world->CreateBody(&cat5BodyDef);
            
            // Create shape definition and add to body
            cat5ShapeDef.shape = &circle;
            cat5ShapeDef.density = 1.0f;
            cat5ShapeDef.friction = 0.001f;
            cat5ShapeDef.restitution = 1.0f;
            _cat5Fixture = cat5Body->CreateFixture(&cat5ShapeDef);
            
            cat5Body->ApplyLinearImpulse(force, cat5BodyDef.position);
            // end cat 5
            numberOfCats++;
        }
    }
    
    
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
        
        if ((contact.fixtureA == _mouseFixture && contact.fixtureB == _cat1Fixture) ||
            (contact.fixtureA == _cat1Fixture && contact.fixtureB == _mouseFixture)) {
            CCLOG(@"Cat1 got the mouse!");
            [self gameOver];
        }
        
        if ((contact.fixtureA == _mouseFixture && contact.fixtureB == _cat2Fixture) ||
            (contact.fixtureA == _cat2Fixture && contact.fixtureB == _mouseFixture)) {
            CCLOG(@"Cat2 got the mouse!");
            [self gameOver];
        }
        
        if ((contact.fixtureA == _mouseFixture && contact.fixtureB == _cat3Fixture) ||
            (contact.fixtureA == _cat3Fixture && contact.fixtureB == _mouseFixture)) {
            CCLOG(@"Cat3 got the mouse!");
            [self gameOver];
        }
        
        if ((contact.fixtureA == _mouseFixture && contact.fixtureB == _cat4Fixture) ||
            (contact.fixtureA == _cat4Fixture && contact.fixtureB == _mouseFixture)) {
            CCLOG(@"Cat4 got the mouse!");
            [self gameOver];
        }
        
        if ((contact.fixtureA == _mouseFixture && contact.fixtureB == _cat5Fixture) ||
            (contact.fixtureA == _cat5Fixture && contact.fixtureB == _mouseFixture)) {
            CCLOG(@"Cat5 got the mouse!");
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
    CCLOG(@"Game over score is: %f", score);
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