//
//  Created by Motohiro Takayama on 3/25/10.
//  Copyright 2010 deadbeaf.org. All rights reserved.
//

#import "WHAnnotationGestureRecognizer.h"
#import "WHTimeAnnotation.h"
#import "WHAnnotationView.h"
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
//   LOG(@"src = %f, %f, dst = %f, %f", srcLocation.x, srcLocation.y, dstLocation.x, dstLocation.y);
   CGContextSetStrokeColorWithColor(ctx, [[UIColor colorWithWhite:0.4 alpha:0.8] CGColor]);
   CGContextSetLineWidth(ctx, 2.0);
   CGContextMoveToPoint(ctx, srcLocation.x, srcLocation.y);
   CGFloat lengths[] = {2, 3};
   CGContextSetLineDash(ctx, 0, lengths, 2);
   CGContextAddLineToPoint(ctx, dstLocation.x, dstLocation.y);
   CGContextStrokePath(ctx);
   
   if (difference != INVALID_DIFFERENCE) {
      // draw difference text
      CGContextSetFillColorWithColor(ctx, [[UIColor colorWithWhite:0.2 alpha:0.8] CGColor]);
      CGContextSelectFont(ctx, "Helvetica", 32.0, kCGEncodingMacRoman);
      CGContextSetTextMatrix(ctx, CGAffineTransformMakeScale(1.0, -1.0));

      NSString *differenceString = (difference > 0)
         ? [NSString stringWithFormat:@"+%d", difference]
         : [NSString stringWithFormat:@"%d", difference];
      CGPoint textPoint = CGPointMake((srcLocation.x + dstLocation.x)/2-32.0,
                                      (srcLocation.y + dstLocation.y)/2-32.0);
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
   [annotation release];
   [overlayLayer release];
   [mapView release];
   [rootView release];
   [super dealloc];
}

- (void) setupOverlayLayer
{
   overlayLayer = [[OverlayLayer alloc] init];
//   overlayLayer.frame = rootView.frame;
   overlayLayer.frame = CGRectMake(0, 0, 1024, 1024); // TODO: ad-hoc
//   overlayLayer.backgroundColor = [[UIColor colorWithWhite:0.1 alpha:0.5] CGColor];
   //   overlayLayer.opaque = 0.5;
}   

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
//   srcLocation = [[touches anyObject] locationInView:rootView];
   srcLocation = [mapView convertCoordinate:annotation.coordinate toPointToView:rootView];
   LOG(@"touchesBegin : (%f, %f)", srcLocation.x, srcLocation.y);

   UIView *view = [mapView viewForAnnotation:annotation];
   CGRect fromRect = view.frame;
   CGPoint fromCenter = view.center;
   CGSize toSize = CGSizeMake(fromRect.size.width * 1.5, fromRect.size.height * 1.5);
   CGRect toRect = CGRectMake(fromCenter.x-toSize.width/2, fromCenter.y-toSize.height/2, toSize.width, toSize.height);
   [UIView beginAnimations:@"beginAnnotationTouch" context:nil];
   view.frame = toRect;
   [UIView commitAnimations];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
   if (! touching) {
      // black out
      [mapView.layer addSublayer:overlayLayer];
   }

   dstLocation = [[touches anyObject] locationInView:rootView];
//   LOG(@"touchesMoved : (%f, %f)", dstLocation.x, dstLocation.y);

   // draw an arrow
   overlayLayer.srcLocation = srcLocation;
   overlayLayer.dstLocation = dstLocation;

   BOOL found = NO;
   // if other annotation is here
   for (WHTimeAnnotation *an in [mapView annotations]) {
      if (an == annotation) continue;
      
      WHAnnotationView *av = (WHAnnotationView *)[mapView viewForAnnotation:an];
      CGPoint annotationPoint = [mapView convertCoordinate:an.coordinate toPointToView:mapView];
      CGRect boundingBox = CGRectMake(annotationPoint.x - av.frame.size.width/2,
                                      annotationPoint.y - av.frame.size.height/2,
                                      av.frame.size.width, av.frame.size.height);
      if (CGRectContainsPoint(boundingBox, dstLocation)) {
         // calculate the time difference
         LOG(@"src time = %d, dst time = %d, time difference = %d", [annotation hour], [an hour], [annotation hour] - [an hour]);
         overlayLayer.difference = annotation.gmtOffset - an.gmtOffset;
         
         if (! av.calculatingDifference) {
            
            CGRect fromRect = av.frame;
            CGPoint fromCenter = av.center;
            CGSize toSize = CGSizeMake(fromRect.size.width * 1.5, fromRect.size.height * 1.5);
            CGRect toRect = CGRectMake(fromCenter.x-toSize.width/2, fromCenter.y-toSize.height/2, toSize.width, toSize.height);
            [UIView beginAnimations:@"beginAnnotationTouch" context:nil];
            av.frame = toRect;
            [UIView commitAnimations];
            av.calculatingDifference = YES;
         }
         found = YES;
         break;
      } else {
         if (av.calculatingDifference) {
            // scale down
            
            CGPoint fromCenter = av.center;
            CGSize toSize = CGSizeMake(48, 48);
            CGRect toRect = CGRectMake(fromCenter.x-toSize.width/2, fromCenter.y-toSize.height/2, toSize.width, toSize.height);
            [UIView beginAnimations:@"endedAnnotationTouch" context:nil];
            av.frame = toRect;
            [UIView commitAnimations];

            av.calculatingDifference = NO;
         }
      }
   }
   if (! found)
      overlayLayer.difference = INVALID_DIFFERENCE;
   
   [overlayLayer setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
   LOG(@"touchesEnded");
   touching = NO;
   // revert to the normal view
   [overlayLayer removeFromSuperlayer];

   UIView *view = [mapView viewForAnnotation:annotation];
//   CGRect fromRect = view.frame;
   CGPoint fromCenter = view.center;
   CGSize toSize = CGSizeMake(48, 48);
   CGRect toRect = CGRectMake(fromCenter.x-toSize.width/2, fromCenter.y-toSize.height/2, toSize.width, toSize.height);
   [UIView beginAnimations:@"endedAnnotationTouch" context:nil];
   view.frame = toRect;
   [UIView commitAnimations];
}
/*
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
   LOG(@"touchesCancelled");
   [super touchesCancelled:touches withEvent:event];
}

- (void)reset
{
   LOG(@"reset");
   [super reset];
}

- (void)ignoreTouch:(UITouch *)touch forEvent:(UIEvent *)event
{
   LOG(@"ignoreTouch");
   [super ignoreTouch:touch forEvent:event];
}

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer
{
   LOG(@"canBePreventedByGestureRecognizer");
   return NO;
}

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer
{
   LOG(@"canPreventGestureRecognizer");
   return NO;
}
*/
@end