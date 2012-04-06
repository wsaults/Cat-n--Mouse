//
//  CCSprite+DisableTouch.m
//

#import "CCSprite+DisableTouch.h"


@implementation CCSprite (DisableTouch)

-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    return YES;
}

-(void)disableTouch
{
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:-1000 swallowsTouches:YES];
}

-(void)enableTouch
{
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
}

@end
