//
//  CCSprite+DisableTouch.h
//

#import "cocos2d.h"


@interface CCSprite (DisableTouch) <CCTargetedTouchDelegate>

-(void)disableTouch;
-(void)enableTouch;

@end
