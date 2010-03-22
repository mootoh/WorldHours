//
//  WorldHoursViewController.m
//  WorldHours
//
//  Created by Motohiro Takayama on 3/20/10.
//  Copyright deadbeaf.org 2010. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "WorldHoursViewController.h"
#import "HourView.h"
#import "HourLayer.h"
#import "WHTimeAnnotation.h"

@interface WHTimeAnnotationView : MKAnnotationView
@end

@implementation WHTimeAnnotationView

- (void) drawRect:(CGRect) rect
{
   CGContextRef context = UIGraphicsGetCurrentContext();
   CGColorRef color = [[UIColor blueColor] CGColor];
   CGContextSetStrokeColorWithColor(context, color);
   
   CGFloat lineWidth = rect.size.width*2;
   CGContextSetLineWidth(context, lineWidth);
   
   CGContextMoveToPoint(context, 0.0f, 0.0f);
   CGContextAddLineToPoint(context, 0.0f, rect.size.height);
   CGContextStrokePath(context);   
}

@end

@implementation VerticalView

- (void) drawRect:(CGRect)rect
{
   CGContextRef context = UIGraphicsGetCurrentContext();
   CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
   
   CGFloat lineWidth = 5.0f;
   CGContextSetLineWidth(context, lineWidth);

   for (int i=0; i<12; i++) {
      CGContextMoveToPoint(context, i * 15.0f, 0.0f);
      CGContextAddLineToPoint(context, i * 15.0f, rect.size.height);
      CGContextStrokePath(context);
   }
}

@end

@implementation WorldHoursViewController

- (void) showHours
{   
   NSCalendar *calendar = [NSCalendar currentCalendar];
   NSTimeZone *gmtTimeZone = [NSTimeZone timeZoneWithName:@"GMT"];
   [calendar setTimeZone:gmtTimeZone];
   NSInteger hour = [[calendar components:NSHourCalendarUnit fromDate:[NSDate date]] hour];

   for (int i=0; i<24; i++) {
      HourView *hv = [[HourView alloc] initWithFrame:CGRectZero];
      CLLocationCoordinate2D loc = {0.0, (i < 12 ? 0.0 : -180.0) + 15.0 * (i < 12 ? i : i-12)};
      hv.location = loc;
      hv.hour = (hour + i) % 24;
      [hv update:theMapView forView:self.view];
      [self.view addSubview:hv];
      [hourViews addObject:hv];
      [hv release];   
   }
}

- (void) showHourLayers
{
   NSCalendar *calendar = [NSCalendar currentCalendar];
   NSTimeZone *gmtTimeZone = [NSTimeZone timeZoneWithName:@"GMT"];
   [calendar setTimeZone:gmtTimeZone];
   NSInteger hour = [[calendar components:NSHourCalendarUnit fromDate:[NSDate date]] hour];
   
   for (int i=0; i<24; i++) {
      HourLayer *layer = [[HourLayer alloc] init];
      CLLocationCoordinate2D loc = {0.0, (i < 12 ? 0.0 : -180.0) + 15.0 * (i < 12 ? i : i-12)};
      layer.location = loc;
      layer.hour = (hour + i) % 24;
      [layer update:theMapView forView:self.view];
      [theMapView.layer addSublayer:layer];
      [hourLayers addObject:layer];
      [layer setNeedsDisplay];
      [layer release];
   }
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
   [super viewDidLoad];
   hourViews = [[NSMutableArray alloc] init];
   hourLayers = [[NSMutableArray alloc] init];

   MKCoordinateRegion nextCenter = {{40, 0}, {150, 360}};
   theMapView.region = nextCenter;
   
   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tapped:) name:@"tapped" object:nil];
   
   UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
   [theMapView addGestureRecognizer:tapGR];
   tapGR.delegate = self;
   [tapGR release];
}

- (void) viewDidAppear:(BOOL)animated
{
//   [self performSelector:@selector(showHours) withObject:nil afterDelay:0.1f];
   [self performSelector:@selector(showHourLayers) withObject:nil afterDelay:0.1f];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
   return YES;
}

- (void)didReceiveMemoryWarning
{
   [super didReceiveMemoryWarning];
}

- (void)dealloc
{
   [hourLayers release];
   [hourViews release];
   [super dealloc];
}

- (void) tapped:(NSNotification *)notification
{
   CGPoint point = [[[notification userInfo] objectForKey:@"point"] CGPointValue];
   CLLocationCoordinate2D coord = [theMapView convertPoint:point toCoordinateFromView:self.view];
   NSLog(@"coord = %f, %f", coord.latitude, coord.longitude);
   WHTimeAnnotation *annotation = [[WHTimeAnnotation alloc] initWithCoordinate:coord];
//   [theMapView addAnnotation:annotation];
   NSLog(@"annotation count = %d", [[theMapView annotations] count]);
   [annotation release];
}

#pragma mark MapViewDelegate

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
   [UIView beginAnimations:@"hourViews" context:nil];
   for (HourLayer *layer in hourLayers) {
//      [layer setNeedsDisplay];
      [layer update:mapView forView:self.view];
   }

   for (HourView *hv in hourViews)
      [hv update:mapView forView:self.view];
   [UIView commitAnimations];

//   for (HourLayer *layer in hourLayers)
//      [layer setNeedsDisplay];
}

- (void) handleGesture:(UITapGestureRecognizer *)recognizer
{
   NSLog(@"handleGesture");
   CGPoint point = [recognizer locationInView:theMapView];
   CLLocationCoordinate2D coord = [theMapView convertPoint:point toCoordinateFromView:self.view];
   NSLog(@"coord = %f, %f", coord.latitude, coord.longitude);
   WHTimeAnnotation *annotation = [[WHTimeAnnotation alloc] initWithCoordinate:coord];
   [theMapView addAnnotation:annotation];
   NSLog(@"annotation count = %d", [[theMapView annotations] count]);
   [annotation release];   
}

@end