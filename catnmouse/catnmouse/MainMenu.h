//
//  MainMenu.h
//  catnmouse
//
//  Created by William Saults on 3/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCScene.h"

@class AppDelegate;

@interface MainMenu : CCScene {
    AppDelegate *delegate;
}

- (void)playGame;

@end
