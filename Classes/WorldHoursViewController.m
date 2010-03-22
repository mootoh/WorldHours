//
//  WorldHoursViewController.m
//  WorldHours
//
//  Created by Motohiro Takayama on 3/20/10.
//  Copyright deadbeaf.org 2010. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "WorldHoursViewController.h"
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

@interface PinTappedRecognizer : UITapGestureRecognizer
{
   id <MKAnnotation> annotation;
}

@property (nonatomic, assign) id <MKAnnotation> annotation;
@end

@implementation PinTappedRecognizer
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

@implementation WorldHoursViewController

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

- (void)viewDidLoad
{
   [super viewDidLoad];
   hourLayers = [[NSMutableArray alloc] init];

   MKCoordinateRegion nextCenter = {{40, 0}, {150, 360}};
   theMapView.region = nextCenter;
   
   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(parseFinished:) name:@"parseFinished" object:nil];
   
   UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
   [theMapView addGestureRecognizer:tapGR];
   tapGR.delegate = self;
   [tapGR release];
}

- (void) viewDidAppear:(BOOL)animated
{
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
   [super dealloc];
}

- (void) parseFinished:(NSNotification *)notification
{
//   WHTimeAnnotation *annotation = [[notification userInfo] objectForKey:@"annotation"];
//   [theMapView selectAnnotation:annotation animated:YES];
//   NSLog(@"selected = %d", [[theMapView selectedAnnotations] count]);
}

#pragma mark MapViewDelegate

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
   [UIView beginAnimations:@"hourViews" context:nil];
   
   for (HourLayer *layer in hourLayers)
      [layer update:mapView forView:self.view];

   [UIView commitAnimations];
}

- (MKAnnotationView *)mapView:(MKMapView *)map viewForAnnotation:(id <MKAnnotation>)annotation
{
   static NSString *AnnotationViewID = @"annotationViewID";
   
#ifdef NO_USE_PIN
   WHTimeAnnotationView *annotationView =
   (WHTimeAnnotationView *)[map dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
   if (annotationView == nil)
   {
      annotationView = [[[WHTimeAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID] autorelease];
   }
#endif // NO_USE_PIN

   MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[map dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
   if (annotationView == nil) {
      annotationView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID] autorelease];
      annotationView.canShowCallout = YES;
   } else {
      for (UIGestureRecognizer *gr in annotationView.gestureRecognizers)
         [annotationView removeGestureRecognizer:gr];
   }

   PinTappedRecognizer *gr = [[PinTappedRecognizer alloc] initWithTarget:self action:@selector(annotationTapped:)];
   [annotationView addGestureRecognizer:gr];
   gr.delegate = self;
   gr.annotation = annotation;
   [gr release];
   
   return annotationView;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
   [theMapView selectAnnotation:[[theMapView annotations] lastObject] animated:YES];
}

#pragma mark UIGestureRecognizerDelegate

- (void) handleGesture:(UITapGestureRecognizer *)recognizer
{
   CGPoint point = [recognizer locationInView:theMapView];
   CLLocationCoordinate2D coord = [theMapView convertPoint:point toCoordinateFromView:self.view];
//   NSLog(@"coord = %f, %f", coord.latitude, coord.longitude);
   WHTimeAnnotation *annotation = [[WHTimeAnnotation alloc] initWithCoordinate:coord];
   [theMapView addAnnotation:annotation];
//   NSLog(@"annotation count = %d", [[theMapView annotations] count]);
   [annotation release];
}

- (void) annotationTapped:(PinTappedRecognizer *)recognizer
{
   [theMapView removeAnnotation:recognizer.annotation];
}
@end