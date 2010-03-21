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
   NSCalendar *calendar = [NSCalendar currentCalendar];
   NSTimeZone *gmtTimeZone = [NSTimeZone timeZoneWithName:@"GMT"];
   [calendar setTimeZone:gmtTimeZone];
   NSInteger hour = [[calendar components:NSHourCalendarUnit fromDate:[NSDate date]] hour];
 
   for (int i=0; i<24; i++) {
      HourView *hv = [[HourView alloc] initWithFrame:CGRectZero];
      hv.backgroundColor = [colors objectAtIndex:(hour+i)%24];
      CLLocationCoordinate2D loc = {0.0, (i < 12 ? 0.0 : -180.0) + 15.0 * (i < 12 ? i : i-12)};
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
   
   colors = [NSArray arrayWithObjects:
             [UIColor colorWithRed:0.20 green:0.20 blue:0.20 alpha:0.5], // AM 0
             [UIColor colorWithRed:0.25 green:0.25 blue:0.25 alpha:0.5],
             [UIColor colorWithRed:0.30 green:0.30 blue:0.30 alpha:0.5],
             [UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:0.5],
             [UIColor colorWithRed:0.40 green:0.40 blue:0.40 alpha:0.5],
             [UIColor colorWithRed:0.45 green:0.45 blue:0.45 alpha:0.5], // AM 5
             [UIColor colorWithRed:0.50 green:0.50 blue:0.50 alpha:0.4],
             [UIColor colorWithRed:0.55 green:0.55 blue:0.55 alpha:0.4],
             [UIColor colorWithRed:0.60 green:0.60 blue:0.60 alpha:0.3], // AM 8
             [UIColor colorWithRed:0.65 green:0.65 blue:0.65 alpha:0.3],

             [UIColor colorWithRed:0.70 green:0.70 blue:0.70 alpha:0.2],
             [UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:0.2],
             [UIColor colorWithRed:0.80 green:0.80 blue:0.80 alpha:0.1], // noon
             [UIColor colorWithRed:0.90 green:0.85 blue:0.85 alpha:0.4],
             [UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:0.5], // PM 2
             [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:0.4],
             [UIColor colorWithRed:0.80 green:0.80 blue:0.80 alpha:0.2],
             [UIColor colorWithRed:0.70 green:0.70 blue:0.70 alpha:0.3],
             [UIColor colorWithRed:0.50 green:0.50 blue:0.50 alpha:0.3], // PM 6
             [UIColor colorWithRed:0.45 green:0.45 blue:0.45 alpha:0.4],

             [UIColor colorWithRed:0.40 green:0.40 blue:0.40 alpha:0.4],
             [UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:0.5],
             [UIColor colorWithRed:0.30 green:0.30 blue:0.30 alpha:0.5],
             [UIColor colorWithRed:0.25 green:0.25 blue:0.25 alpha:0.5],
             nil];
   [colors retain];

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