//
//  WHAnnotationView.m
//  WorldHours
//
//  Created by Motohiro Takayama on 3/25/10.
//  Copyright 2010 deadbeaf.org. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "WHAppDelegate.h"
#import "WorldHoursViewController.h"
#import "WHAnnotationView.h"
#import "WHAnnotationGestureRecognizer.h"
#import "WHTimeAnnotation.h"

@implementation WHAnnotationLeftCalloutView
@synthesize mapView;

- (id) initWithFrame:(CGRect)frame
{
   if (self = [super initWithFrame:frame]) {
      self.backgroundColor = [UIColor clearColor];
      UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrowButton.png"]];
      [self addSubview:iv];
      [iv release];
   }
   return self;
}

- (void) dealloc
{
   LOG(@"WHAnnotationLeftCalloutView dealloc");
   [mapView release];
   [super dealloc];
}
   
- (void) setupGestureRecognizer:(WHTimeAnnotation *)annotation
{
   WHAnnotationGestureRecognizer *gr = [[WHAnnotationGestureRecognizer alloc] initWithTarget:nil action:nil];
   gr.mapView = mapView;
   gr.annotation = annotation;
   
   WHAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
   gr.rootView = appDelegate.viewController.view;
   [gr setupOverlayLayer];
   [self addGestureRecognizer:gr];
   [gr release];
}

- (void) drawRect:(CGRect)rect
{
//   CGContextRef context = UIGraphicsGetCurrentContext();   
}

@end

@implementation WHAnnotationRightCalloutView
@synthesize annotation;

- (id) initWithFrame:(CGRect)frame
{
   if (self = [super initWithFrame:frame]) {
      UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
      [self addGestureRecognizer:gr];
      [gr release];
      
      UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"closeButton.png"]];
      [self addSubview:iv];
      [iv release];
   }
   return self;
}

- (void) dealloc
{
   LOG(@"WHAnnotationRightCalloutView dealloc");
   [annotation release];
   [super dealloc];
}

- (void) tapped
{
   [[NSNotificationCenter defaultCenter] postNotificationName:@"removeAnnotation" object:nil userInfo:[NSDictionary dictionaryWithObject:annotation forKey:@"annotation"]];
}

@end

@implementation WHAnnotationView

@synthesize hour, minute, frequency, working, mapView, calculatingDifference;

static UIColor *s_dayColor   = nil;
static UIColor *s_nightColor = nil;

+ (UIColor *) dayColor
{
   if (s_dayColor == nil)
      s_dayColor = [[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.8] retain];
   return s_dayColor;
}

+ (UIColor *) nightColor
{
   if (s_nightColor == nil)
      s_nightColor = [[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.8] retain];
   return s_nightColor;
}

- (id) initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
   if (self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier]) {
      self.backgroundColor = [UIColor clearColor];
      hour = 0;
      minute = 0;
      frequency = 60.0;
      self.frame = CGRectMake(0, 0, 48, 48);
      state = STATE_INITIAL;
      self.canShowCallout = YES;
      calculatingDifference = NO;
   }
   return self;
}

- (void)prepareForReuse
{
//   [self.leftCalloutAccessoryView release];
   self.leftCalloutAccessoryView = nil;
//   [self.rightCalloutAccessoryView release];
   self.rightCalloutAccessoryView = nil;
    
   if (working)
      [self stop];
}

- (void) setupCalloutView
{   
   WHAnnotationLeftCalloutView *leftCalloutView = [[WHAnnotationLeftCalloutView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
   leftCalloutView.mapView = mapView;
   [leftCalloutView setupGestureRecognizer:self.annotation];
   self.leftCalloutAccessoryView = leftCalloutView;
   [leftCalloutView release];

   WHAnnotationRightCalloutView *rightCalloutView = [[WHAnnotationRightCalloutView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
   rightCalloutView.annotation = self.annotation;
   self.rightCalloutAccessoryView = rightCalloutView;
   [rightCalloutView release];
}

- (void)drawRect:(CGRect)rect
{
   CGContextRef context = UIGraphicsGetCurrentContext();
   CGColorRef backColor = (hour >= 6 && hour < 18) ? [[WHAnnotationView dayColor] CGColor] : [[WHAnnotationView nightColor] CGColor];
   CGColorRef foreColor = (hour >= 6 && hour < 18) ? [[WHAnnotationView nightColor] CGColor] : [[WHAnnotationView dayColor] CGColor];
   
   // circle around
   CGRect ellipseRect = CGRectMake(rect.origin.x+5, rect.origin.y+5, rect.size.width-10, rect.size.height-10);
   CGContextSetStrokeColorWithColor(context, foreColor);
   CGContextSetLineWidth(context, 1.7f);
   CGContextSetFillColorWithColor(context, backColor);
   CGContextAddEllipseInRect(context, ellipseRect);
   CGContextFillPath(context);
   CGContextAddEllipseInRect(context, ellipseRect);
   CGContextStrokePath(context);
   
   CGPoint ellipseCenter = {rect.origin.x + rect.size.width/2, rect.origin.y + rect.size.height/2};
   CGFloat minuteHand = rect.size.height * 0.35;
   CGFloat hourHand = rect.size.height * 0.22;
   
   CGContextSetStrokeColorWithColor(context, foreColor);
   
   // minuteHand
   CGContextSetLineWidth(context, 1.5f);
   CGContextMoveToPoint(context, ellipseCenter.x, ellipseCenter.y);
   CGContextAddLineToPoint(context,
                           ellipseCenter.x + sinf(M_PI / 180.0f * minute * 6.0f) * minuteHand,
                           ellipseCenter.y - cosf(M_PI / 180.0f * minute * 6.0f) * minuteHand);
   CGContextStrokePath(context);
   
   // hourHand
   CGContextSetLineWidth(context, 3.5f);
   CGContextMoveToPoint(context, ellipseCenter.x, ellipseCenter.y);
   CGContextAddLineToPoint(context,
                           ellipseCenter.x + sinf(M_PI / 180.0f * (hour * 30.0f + minute * 0.5f)) * hourHand,
                           ellipseCenter.y - cosf(M_PI / 180.0f * (hour * 30.0f + minute * 0.5f)) * hourHand);
   CGContextStrokePath(context);
   
   // center circle
   CGRect innerEllipseRect = CGRectMake(ellipseCenter.x-3, ellipseCenter.y-3, 6, 6);
   CGContextSetStrokeColorWithColor(context, foreColor);
   CGContextSetFillColorWithColor(context, foreColor);
   CGContextAddEllipseInRect(context, innerEllipseRect);
   CGContextFillPath(context);
}

- (void)dealloc
{
   if (working)
      [self stop];
   [super dealloc];
}

- (void) updateTime
{
   LOG(@"updateTime:%02d:%02d", hour, minute);
   if (++minute >= 60) {
      minute = 0;
      if (++hour >= 24)
         hour = 0;
   }
   
   [self setNeedsDisplay];
   if (working)
      [self performSelector:@selector(updateTime) withObject:nil afterDelay:frequency];
}


- (void) start
{
   working = YES;
   [self updateTime];
}

- (void) stop
{
   working = NO;
}

- (void) annotationTapped:(WHAnnotationGestureRecognizer *)recognizer
{
   if (state == STATE_INITIAL)
      [self setSelected:YES animated:YES];
}

@end