//
//  CCSprite+AddOns.h
//  Mole It
//
//  Created by Todd Perkins on 7/28/11.
//  Copyright 2011 Wedgekase Games, LLC. All rights reserved.
//

#import "cocos2d.h"


@interface GameButton: CCSprite
{
    
}

+(id)buttonWithText: (NSString *)buttonText isBig:(BOOL)big;
+(id)buttonWithText: (NSString *)buttonText;


-(id)initWithText: (NSString *)buttonText isBig:(BOOL)big;


@end
