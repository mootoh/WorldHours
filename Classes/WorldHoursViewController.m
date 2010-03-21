//
//  WorldHoursViewController.m
//  WorldHours
//
//  Created by Motohiro Takayama on 3/20/10.
//  Copyright deadbeaf.org 2010. All rights reserved.
//

#import "WorldHoursViewController.h"
#import "HourView.h"

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
   for (int i=0; i<12; i++) {
      HourView *hv = [[HourView alloc] initWithFrame:CGRectZero];
      CGFloat colorFactor = (CGFloat)i / 24.0f;
      hv.backgroundColor = [UIColor colorWithRed:colorFactor green:colorFactor blue:colorFactor alpha:0.7];
      CLLocationCoordinate2D loc = {0.0, 15.0 * i};
      hv.location = loc;
      [hv update:theMapView forView:self.view];
      [self.view addSubview:hv];
      [hourViews addObject:hv];
      [hv release];   
   }

   for (int i=1; i<=12; i++) {
      HourView *hv = [[HourView alloc] initWithFrame:CGRectZero];
      CGFloat colorFactor = (CGFloat)i / 24.0f;
      hv.backgroundColor = [UIColor colorWithRed:colorFactor green:colorFactor blue:colorFactor alpha:0.7];
      CLLocationCoordinate2D loc = {0.0, -15.0 * i};
      hv.location = loc;
      [hv update:theMapView forView:self.view];
      [self.view addSubview:hv];
      [hourViews addObject:hv];
      [hv release];
   }
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
   [super viewDidLoad];

   hourViews = [[NSMutableSet alloc] init];

   MKCoordinateRegion nextCenter = {{40, 0}, {150, 360}};
   theMapView.region = nextCenter;
}

- (void) viewDidAppear:(BOOL)animated
{
   [self performSelector:@selector(showHours) withObject:nil afterDelay:0.1f];
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
   [hourViews release];
   [super dealloc];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
//   MKCoordinateRegion region = mapView.region;
//   NSLog(@"region changed to: (%f, %f), %f, %f", region.center.latitude, region.center.longitude, region.span.latitudeDelta, region.span.longitudeDelta);
//   CGRect rect = [mapView convertRegion:region toRectToView:self.view];
//   NSLog(@"rect = (%f, %f), (%f, %f)", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
//   CGRect rectInMap = [mapView convertRegion:region toRectToView:mapView];
//   NSLog(@"rectInMap = (%f, %f), (%f, %f)", rectInMap.origin.x, rectInMap.origin.y, rectInMap.size.width, rectInMap.size.height);
   
   [UIView beginAnimations:@"hourViews" context:nil];
   for (HourView *hv in hourViews)
      [hv update:mapView forView:self.view];
   [UIView commitAnimations];
}

@end