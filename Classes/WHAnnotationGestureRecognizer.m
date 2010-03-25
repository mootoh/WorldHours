//
//  Created by Motohiro Takayama on 3/25/10.
//  Copyright 2010 deadbeaf.org. All rights reserved.
//

#import "WHAnnotationGestureRecognizer.h"
#import "WHTimeAnnotation.h"
#import <QuartzCore/QuartzCore.h>

@interface OverlayLayer : CALayer
{
   CGPoint srcLocation, dstLocation;
   NSInteger difference;
}

@property (nonatomic, assign) CGPoint srcLocation;
@property (nonatomic, assign) CGPoint dstLocation;
@property (nonatomic, assign) NSInteger difference;

@end

#define INVALID_DIFFERENCE -32

@implementation OverlayLayer
@synthesize srcLocation, dstLocation, difference;

- (id) init
{
   if (self = [super init]) {
      difference = INVALID_DIFFERENCE;
   }
   return self;
}

- (void)drawInContext:(CGContextRef)ctx
{
   NSLog(@"src = %f, %f, dst = %f, %f",
         srcLocation.x, srcLocation.y, dstLocation.x, dstLocation.y);
   CGContextSetStrokeColorWithColor(ctx, [[UIColor colorWithWhite:0.75 alpha:0.8] CGColor]);
   CGContextSetLineWidth(ctx, 3.0);
   CGContextMoveToPoint(ctx, srcLocation.x, srcLocation.y);
   CGContextAddLineToPoint(ctx, dstLocation.x, dstLocation.y);
   CGContextStrokePath(ctx);
   
   if (difference != INVALID_DIFFERENCE) {
      // draw difference text
      CGContextSetFillColorWithColor(ctx, [[UIColor whiteColor] CGColor]);
      CGContextSelectFont(ctx, "Helvetica", 24.0, kCGEncodingMacRoman);
      CGContextSetTextMatrix(ctx, CGAffineTransformMakeScale(1.0, -1.0));

      NSString *differenceString = [NSString stringWithFormat:@"%d", difference];
      CGPoint textPoint = CGPointMake((srcLocation.x + dstLocation.x)/2-24.0,
                                      (srcLocation.y + dstLocation.y)/2-24.0);
      CGContextShowTextAtPoint(ctx, textPoint.x, textPoint.y, [differenceString UTF8String], [differenceString lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);      
   }
}

@end

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
   [overlayLayer release];
   [super dealloc];
}

- (void) setupOverlayLayer
{
   overlayLayer = [[OverlayLayer alloc] init];
//   overlayLayer.frame = rootView.frame;
   overlayLayer.frame = CGRectMake(0, 0, 1024, 1024); // TODO: ad-hoc
   overlayLayer.backgroundColor = [[UIColor colorWithWhite:0.1 alpha:0.5] CGColor];
   //   overlayLayer.opaque = 0.5;
}   

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
   srcLocation = [[touches anyObject] locationInView:rootView];
   NSLog(@"touchesBegin : (%f, %f)", srcLocation.x, srcLocation.y);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
   if (! touching) {
      // black out
      [mapView.layer addSublayer:overlayLayer];
   }

   dstLocation = [[touches anyObject] locationInView:rootView];
   NSLog(@"touchesMoved : (%f, %f)", dstLocation.x, dstLocation.y);

   // draw an arrow
   overlayLayer.srcLocation = srcLocation;
   overlayLayer.dstLocation = dstLocation;

   BOOL found = NO;
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
         overlayLayer.difference = [annotation hour] - [an hour];
         found = YES;
         break;
      }
   }
   if (! found)
      overlayLayer.difference = INVALID_DIFFERENCE;
   
   [overlayLayer setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
   NSLog(@"touchesEnded");
   touching = NO;
   // revert to the normal view
   [overlayLayer removeFromSuperlayer];
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