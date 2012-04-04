//
//  CCSprite+DisableTouch.h
//  Mole It
//
//  Created by Todd Perkins on 8/1/11.
//  Copyright 2011 Wedgekase Games, LLC. All rights reserved.
//

#import "cocos2d.h"


@interface CCSprite (DisableTouch) <CCTargetedTouchDelegate>

-(void)disableTouch;
-(void)enableTouch;

@end
