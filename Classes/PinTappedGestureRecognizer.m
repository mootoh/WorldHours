//
//  Created by Motohiro Takayama on 3/25/10.
//  Copyright 2010 deadbeaf.org. All rights reserved.
//

#import "PinTappedGestureRecognizer.h"

@implementation PinTappedGestureRecognizer
@synthesize annotation;

- (id) initWithTarget:(id)target action:(SEL)action
{
   if (self = [super initWithTarget:target action:action]) {
      annotation = nil;
   }
   return self;
}

- (void) dealloc
{
   [super dealloc];
}

@end