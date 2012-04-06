//
//  PopUp.m
//  catnmouse
//
//  Created by William Saults on 3/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PopUp.h"
#import "CCSprite+DisableTouch.h"
#import "CCMenuPopup.h"

#define ANIM_SPEED .2f

@implementation PopUp

enum tags
{
    tBG = 1,
};

+ (id)popUpWithTitle:(NSString *)titleText description:(NSString *)description sprite:(CCNode *)sprite
{
    return [[[self alloc] initWithTitle:titleText description:description sprite:sprite]autorelease];
}
- (id)initWithTitle:(NSString *)titleText description:(NSString *)description sprite:(CCNode *)sprite
{
    if((self = [super init])) {
        
        CGSize s = [[CCDirector sharedDirector] winSize];
        container = sprite;
        window = [CCSprite spriteWithSpriteFrameName:@"menu.png"];
        bg = [CCSprite node];
        bg.color = ccBLACK;
        bg.opacity = 0;
        [bg setTextureRect:CGRectMake(0, 0, s.width, s.height)];
        bg.anchorPoint = ccp(0,0);
//        [bg disableTouch];
        window.position = ccp(s.width/2, s.height/2);
        window.scale = .9;
        int fSize = 36;
        CCLabelTTF *title = [CCLabelTTF labelWithString:titleText fontName:@"Helvetica" fontSize:fSize];
        title.opacity = (float)255 * .25f;
        title.position = ccp(window.position.x, window.position.y + window.contentSize.height/3);
        CCLabelTTF *desc = [CCLabelTTF labelWithString:description fontName:@"Helvetica" fontSize:fSize/2];
        
        desc.position = ccp(title.position.x, title.position.y - title.contentSize.height);
        desc.opacity = (float)255 * .75f;
        [window addChild:title z:1];
        [window addChild:desc];
        [self addChild:bg z:-1 tag:tBG];
        [self addChild:window];
         
        [window addChild:container z:2];
        [bg runAction:[CCFadeTo actionWithDuration:ANIM_SPEED / 2 opacity:150]];
        [window runAction:[CCSequence actions:
                           [CCScaleTo actionWithDuration:ANIM_SPEED / 2 scale:1.1],
                           [CCScaleTo actionWithDuration:ANIM_SPEED scale:1.0],
                           nil]];
    }
    return self;
}

- (void)closePopUp
{
//    [(CCSprite *)[self getChildByTag:tBG] enableTouch];
    [window runAction:[CCFadeOut actionWithDuration:ANIM_SPEED]];
    [window runAction:[CCSequence actions:
                       [CCScaleTo actionWithDuration:ANIM_SPEED scale:1.1],
                       [CCCallFunc actionWithTarget:self selector:@selector(allDone)],
                       nil]];
}

- (void)allDone
{
    [self removeFromParentAndCleanup:YES];
}

@end
