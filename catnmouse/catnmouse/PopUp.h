//
//  PopUp.h
//  catnmouse
//
//  Created by William Saults on 3/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCSprite.h"
#import "cocos2d.h"

@interface PopUp : CCSprite {
    CCSprite *window,*bg;
    CCNode *container;
}

+ (id)popUpWithTitle: (NSString *)titleText description:(NSString *)description sprite:(CCNode *)sprite;
- (id)initWithTitle: (NSString *)titleText description:(NSString *)description sprite:(CCNode *)sprite;
- (void)closePopUp;

@end
