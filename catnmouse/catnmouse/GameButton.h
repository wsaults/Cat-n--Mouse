//
//  CCSprite+AddOns.h
//

#import "cocos2d.h"


@interface GameButton: CCSprite
{
    
}

+(id)buttonWithText: (NSString *)buttonText isBig:(BOOL)big;
+(id)buttonWithText: (NSString *)buttonText;


-(id)initWithText: (NSString *)buttonText isBig:(BOOL)big;


@end
