//
//  Created by Motohiro Takayama on 3/25/10.
//  Copyright 2010 deadbeaf.org. All rights reserved.
//

#import "WHAnnotationGestureRecognizer.h"
#import "WHTimeAnnotation.h"

@implementation WHAnnotationGestureRecognizer
@synthesize annotation, mapView, rootView;

- (id) initWithTarget:(id)target action:(SEL)action
{
   if (self = [super initWithTarget:target action:action]) {
      annotation = nil;
      touching = NO;
   }
   return self;
}

- (void) dealloc
{
   [super dealloc];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
   srcLocation = [[touches anyObject] locationInView:rootView];
   NSLog(@"touchesBegin : (%f, %f)", srcLocation.x, srcLocation.y);
   touching = YES;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
   dstLocation = [[touches anyObject] locationInView:rootView];
   NSLog(@"touchesMoved : (%f, %f)", dstLocation.x, dstLocation.y);

   // draw an arrow
   
   // if other annotation is here
   for (WHTimeAnnotation *an in [mapView annotations]) {
      MKAnnotationView *av = [mapView viewForAnnotation:an];
      CGPoint annotationPoint = [mapView convertCoordinate:an.coordinate toPointToView:mapView];
      CGRect boundingBox = CGRectMake(annotationPoint.x - av.frame.size.width/2,
                                      annotationPoint.y - av.frame.size.height/2,
                                      av.frame.size.width, av.frame.size.height);
      if (CGRectContainsPoint(boundingBox, dstLocation)) {
         // calculate the time difference
         NSLog(@"src time = %d, dst time = %d, time difference = %d", [annotation hour], [an hour], [annotation hour] - [an hour]);
         return;
      }
   }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
   NSLog(@"touchesEnded");
   touching = NO;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
   NSLog(@"touchesCancelled");
}

- (void)reset
{
   NSLog(@"reset");
}

- (void)ignoreTouch:(UITouch *)touch forEvent:(UIEvent *)event
{
   NSLog(@"ignoreTouch");
}

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer
{
   NSLog(@"canBePreventedByGestureRecognizer");
   return NO;
}

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer
{
   NSLog(@"canPreventGestureRecognizer");
   return NO;
}

@end