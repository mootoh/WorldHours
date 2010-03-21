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
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
   [super viewDidLoad];
   hourViews = [[NSMutableSet alloc] init];
/*
   for (int i=0; i<24; i++) {
      UIView *v = [[UIView alloc] initWithFrame:CGRectMake(i*self.view.frame.size.height/24.0f, 0, self.view.frame.size.height/24, self.view.frame.size.width)];
      CGFloat colorFactor = (CGFloat)i / 24.0f;
      v.backgroundColor = [UIColor colorWithRed:colorFactor green:colorFactor blue:colorFactor alpha:0.7];
      [theMapView addSubview:v];
      [v release];
   }
*/
   NSLog(@"center = %f, %f, %f, %f", theMapView.region.center.latitude, theMapView.region.center.longitude, theMapView.region.span.latitudeDelta, theMapView.region.span.longitudeDelta);
   
   MKCoordinateRegion nextCenter = {{40, 0}, {150, 360}};
   theMapView.region = nextCenter;

   [self showHours];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
   [hourViews release];
    [super dealloc];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
   MKCoordinateRegion region = mapView.region;
   NSLog(@"region changed to: (%f, %f), %f, %f", region.center.latitude, region.center.longitude, region.span.latitudeDelta, region.span.longitudeDelta);
   CGRect rect = [mapView convertRegion:region toRectToView:self.view];
   NSLog(@"rect = (%f, %f), (%f, %f)", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
   CGRect rectInMap = [mapView convertRegion:region toRectToView:mapView];
   NSLog(@"rectInMap = (%f, %f), (%f, %f)", rectInMap.origin.x, rectInMap.origin.y, rectInMap.size.width, rectInMap.size.height);
   
   [UIView beginAnimations:@"hourViews" context:nil];
   for (HourView *hv in hourViews)
      [hv update:mapView forView:self.view];
   [UIView commitAnimations];
}

@end