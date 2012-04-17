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

@synthesize state = _state, adWhirlView;

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
        // Add at end of init
        self.state = kGameStatePlaying;
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
    pauseButton.position = ccp(s.width/2 - pauseButton.contentSize.width/2, (-s.height/2) + pauseButton.contentSize.height*1.8);
    [self addChild:menu z:100];
    
    int fSize = 28;
    pause = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"ll"] fontName:@"SF_Cartoonist_Hand_Bold.ttf" fontSize:fSize];
    pause.position = ccp(s.width/1.069, s.height/6.6);
    [self addChild:pause z:101];
    
    [self startGame];
}

- (void)startGame
{    
    isThereCheese = NO;
    
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"DST-OriginB.mp3"];
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
    CCSprite *cat1 = [CCSprite spriteWithFile:@"cat1.png" 
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
    CCSprite *cat2 = [CCSprite spriteWithFile:@"cat2.png" 
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
    CCSprite *mouse = [CCSprite spriteWithFile:@"mouse.png" rect:CGRectMake(0, 0, 52, 52)];
    mouse.position = ccp(winSize.width/2, winSize.height/3);
    mouse.tag = 20;
    [self addChild:mouse z:105];
    
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
            CCSprite *cat3 = [CCSprite spriteWithFile:@"cat3.png" 
                                                 rect:CGRectMake(0, 0, 52, 52)];
            cat3.position = ccp(1, 1);
            cat3.tag = 3;
            [self addChild:cat3];
            
            // Create cat3 body 
            b2BodyDef cat3BodyDef;
            cat3BodyDef.type = b2_dynamicBody;
            cat3BodyDef.position.Set(1/PTM_RATIO, 1/PTM_RATIO);
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
            CCSprite *cat4 = [CCSprite spriteWithFile:@"cat4.png" 
                                                 rect:CGRectMake(0, 0, 52, 52)];
            cat4.position = ccp(1, 1);
            cat4.tag = 4;
            [self addChild:cat4];
            
            // Create cat4 body 
            b2BodyDef cat4BodyDef;
            cat4BodyDef.type = b2_dynamicBody;
            cat4BodyDef.position.Set(1/PTM_RATIO, 1/PTM_RATIO);
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
            CCSprite *cat5 = [CCSprite spriteWithFile:@"cat5.png" 
                                                 rect:CGRectMake(0, 0, 52, 52)];
            cat5.position = ccp(1, 1);
            cat5.tag = 5;
            [self addChild:cat5];
            
            // Create cat5 body 
            b2BodyDef cat5BodyDef;
            cat5BodyDef.type = b2_dynamicBody;
            cat5BodyDef.position.Set(1/PTM_RATIO, 1/PTM_RATIO);
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
    
#pragma mark - Random Cheese Bonus
    // Random Cheese bonus!
//    r = arc4random() % 500; // Random number from 0-500
    r = 0;
    if (r == 10 && isThereCheese == NO) {
        // Make a block of 10pt cheese - Small Block
        isThereCheese = YES;
        
        
        // Create sprite and add it to the layer
        CCSprite *smallCheese = [CCSprite spriteWithFile:@"cheese10.png" 
                                                    rect:CGRectMake(0, 0, 32, 32)];
        [smallCheese setPosition:ccp(s.width/2,s.height/2)];
        smallCheese.tag = 100;
        [self addChild:smallCheese z:999];
        
        // Create block body
        b2BodyDef blockBodyDef;
        blockBodyDef.type = b2_dynamicBody;
        blockBodyDef.position.Set(s.width/2,s.height/2);
        blockBodyDef.userData = smallCheese;
        b2Body *blockBody = _world->CreateBody(&blockBodyDef);
        
        // Create block shape
        b2PolygonShape blockShape;
        blockShape.SetAsBox(smallCheese.contentSize.width/PTM_RATIO/2,
                            smallCheese.contentSize.height/PTM_RATIO/2);
        
        // Create shape definition and add to body
        b2FixtureDef blockShapeDef;
        blockShapeDef.shape = &blockShape;
        blockShapeDef.density = 10.0;
        blockShapeDef.friction = 0.0;
        blockShapeDef.restitution = 0.1f;
        blockBody->CreateFixture(&blockShapeDef);
        
        
    } else if ((r == 1 || r == 5) && isThereCheese == NO) {
        // Make a block of 5pt cheese - Big Block
        isThereCheese = YES;
        
        // Create sprite and add it to the layer
        CCSprite *bigCheese = [CCSprite spriteWithFile:@"cheese5.png" 
                                                  rect:CGRectMake(0, 0, 64, 64)];
        [bigCheese setPosition:ccp(s.width/2,s.height/2)];
        bigCheese.tag = 100;
        [self addChild:bigCheese z:999];
        
        // Create block body
        b2BodyDef blockBodyDef;
        blockBodyDef.type = b2_dynamicBody;
        blockBodyDef.position.Set(s.width/2,s.height/2);
        blockBodyDef.userData = bigCheese;
        b2Body *blockBody = _world->CreateBody(&blockBodyDef);
        
        // Create block shape
        b2PolygonShape blockShape;
        blockShape.SetAsBox(bigCheese.contentSize.width/PTM_RATIO/2,
                            bigCheese.contentSize.height/PTM_RATIO/2);
        
        // Create shape definition and add to body
        b2FixtureDef blockShapeDef;
        blockShapeDef.shape = &blockShape;
        blockShapeDef.density = 10.0;
        blockShapeDef.friction = 0.0;
        blockShapeDef.restitution = 0.1f;
        blockBody->CreateFixture(&blockShapeDef);
    }
    // end cheese bonus
    
    std::vector<b2Body *>toDestroy;
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
        
//        if ((contact.fixtureA == _mouseFixture && contact.fixtureB == _cheese10Fixture) ||
//            (contact.fixtureA == _cheese10Fixture && contact.fixtureB == _mouseFixture)) {
//            CCLOG(@"Got +10 Cheese Points!");
//            
//        }
//        
//        if ((contact.fixtureA == _mouseFixture && contact.fixtureB == _cheese5Fixture) ||
//            (contact.fixtureA == _cheese5Fixture && contact.fixtureB == _mouseFixture)) {
//            CCLOG(@"Got +5 Cheese Points!");
//        }
        
        b2Body *bodyA = contact.fixtureA->GetBody();
        b2Body *bodyB = contact.fixtureB->GetBody();
        if (bodyA->GetUserData() != NULL && bodyB->GetUserData() != NULL) {
            CCSprite *spriteA = (CCSprite *) bodyA->GetUserData();
            CCSprite *spriteB = (CCSprite *) bodyB->GetUserData();
            
            // Sprite A = ball, Sprite B = Block
            if (spriteA.tag == 20 && spriteB.tag == 100) {
                if (std::find(toDestroy.begin(), toDestroy.end(), bodyB) 
                    == toDestroy.end()) {
                    toDestroy.push_back(bodyB);
                    CCLOG(@"Got Cheese Points!");
                }
            }
            // Sprite B = block, Sprite A = ball
            else if (spriteB.tag == 100 && spriteA.tag == 20) {
                if (std::find(toDestroy.begin(), toDestroy.end(), bodyA) 
                    == toDestroy.end()) {
                    toDestroy.push_back(bodyA);
                    CCLOG(@"Got Cheese Points!");
                }
            }        
        }
    }
    std::vector<b2Body *>::iterator pos2;
    for(pos2 = toDestroy.begin(); pos2 != toDestroy.end(); ++pos2) {
        b2Body *body = *pos2;     
        if (body->GetUserData() != NULL) {
            CCSprite *sprite = (CCSprite *) body->GetUserData();
            [self removeChild:sprite cleanup:YES];
        }
        _world->DestroyBody(body);
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
    [[SimpleAudioEngine sharedEngine] playEffect:@"sadwhisle.wav"];
    [delegate finishedWithScore:score];
    [delegate checkAchievements:score];
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
    pause.visible = NO;
    
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
    pause.visible = YES;
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

- (void)onEnter
{
    //1
    viewController = [(AppDelegate *)[[UIApplication sharedApplication] delegate] viewController];
    //2
    self.adWhirlView = [AdWhirlView requestAdWhirlViewWithDelegate:self];
    //3
    self.adWhirlView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    
    //4
    [adWhirlView updateAdWhirlConfig];
    //5
	CGSize adSize = [adWhirlView actualAdSize];
    //6
    CGSize winSize = [CCDirector sharedDirector].winSize;
    //7
	self.adWhirlView.frame = CGRectMake((winSize.width/2)-(adSize.width/2),winSize.height-adSize.height,winSize.width,adSize.height);
    //8
	self.adWhirlView.clipsToBounds = YES;
    //9
    [viewController.view addSubview:adWhirlView];
    //10
    [viewController.view bringSubviewToFront:adWhirlView];
    //11
    [super onEnter];
}

- (void)onExit
{
    [[CCTouchDispatcher sharedDispatcher] removeAllDelegates];
    
    if (adWhirlView) {
        [adWhirlView removeFromSuperview];
        [adWhirlView replaceBannerViewWith:nil];
        [adWhirlView ignoreNewAdRequests];
        [adWhirlView setDelegate:nil];
        self.adWhirlView = nil;
    }
    [super onExit];
}

- (void)adWhirlWillPresentFullScreenModal {
    
    if (self.state == kGameStatePlaying) {
        
        [[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
        
        [[CCDirector sharedDirector] pause];
    }
}

- (void)adWhirlDidDismissFullScreenModal {
    
    if (self.state == kGameStatePaused)
        return;
    
    else {
        self.state = kGameStatePlaying;
        [[SimpleAudioEngine sharedEngine] resumeBackgroundMusic];
        [[CCDirector sharedDirector] resume];
        
    }
}

- (NSString *)adWhirlApplicationKey {
    return @"983b6dbf6d2443bf99a72a65768cd5ca";
}

- (UIViewController *)viewControllerForPresentingModalView {
    return viewController;    
}

-(void)adjustAdSize {
	//1
	[UIView beginAnimations:@"AdResize" context:nil];
	[UIView setAnimationDuration:0.2];
	//2
	CGSize adSize = [adWhirlView actualAdSize];
	//3
	CGRect newFrame = adWhirlView.frame;
	//4
	newFrame.size.height = adSize.height;
    
   	//5 
    CGSize winSize = [CCDirector sharedDirector].winSize;
    //6
	newFrame.size.width = winSize.width;
	//7
	newFrame.origin.x = (self.adWhirlView.bounds.size.width - adSize.width)/2;
    
    //8 
	newFrame.origin.y = (winSize.height - adSize.height);
	//9
	adWhirlView.frame = newFrame;
	//10
	[UIView commitAnimations];
}

- (void)adWhirlDidReceiveAd:(AdWhirlView *)adWhirlVieww {
    //1
    [adWhirlView rotateToOrientation:UIInterfaceOrientationLandscapeRight];
	//2    
    [self adjustAdSize];
    
}

- (void)dealloc
{
    self.adWhirlView.delegate = nil;
    self.adWhirlView = nil;
    delete _world;
    _groundBody = NULL;
    delete _contactListener;
    CCLOG(@"dealloc: %@", self);
    [super dealloc];
}

@end