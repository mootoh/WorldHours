//
//  WorldHoursViewController.m
//  WorldHours
//
//  Created by Motohiro Takayama on 3/20/10.
//  Copyright deadbeaf.org 2010. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "WorldHoursViewController.h"
#import "WHHourLayer.h"
#import "WHTimeAnnotation.h"
#import "WHAnnotationView.h"
#import "WHMoreViewController.h"
#import "WHAppDelegate.h"
#import "WHAnnotationGestureRecognizer.h"

@implementation WorldHoursViewController

- (void) showAnnotations
{
   WHAppDelegate *appDelegate = (WHAppDelegate *)[UIApplication sharedApplication].delegate;
   for (NSString *loc in appDelegate.locations) {
      CGFloat lat, lon;
      sscanf([loc UTF8String], "%f %f", &lat, &lon);
      CLLocationCoordinate2D coord = {lat, lon};
      WHTimeAnnotation *annotation = [[WHTimeAnnotation alloc] initWithCoordinate:coord];
      [annotation search];
   }
}

- (void) hideAnnotations
{
   [theMapView removeAnnotations:theMapView.annotations];
}

- (void) showHourLayers
{
   NSCalendar *calendar = [NSCalendar currentCalendar];
   NSTimeZone *gmtTimeZone = [NSTimeZone timeZoneWithName:@"GMT"];
   [calendar setTimeZone:gmtTimeZone];
   NSInteger hour = [[calendar components:NSHourCalendarUnit fromDate:[NSDate date]] hour];
   
   for (int i=0; i<24; i++) {
      WHHourLayer *layer = [[WHHourLayer alloc] init];
      CLLocationCoordinate2D loc = {0.0, (i < 12 ? 0.0 : -180.0) + 15.0 * (i < 12 ? i : i-12)};
      layer.location = loc;
      layer.hour = (hour + i) % 24;
      [layer update:theMapView forView:self.view];
      [hourLayers addObject:layer];
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
   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeAnnotation:) name:@"removeAnnotation" object:nil];
   
   UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mapTapped:)];
   [theMapView addGestureRecognizer:tapGR];
   tapGR.delegate = self;
   [tapGR release];
   
   [segmentedControl addTarget:self action:@selector(modeSwitched) forControlEvents:UIControlEventValueChanged];

   [self showAnnotations];
}

- (void) viewDidAppear:(BOOL)animated
{
   [self performSelector:@selector(showHourLayers) withObject:nil afterDelay:0.1f];
   [self modeSwitched];
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
   WHTimeAnnotation *annotation = [[notification userInfo] objectForKey:@"annotation"];
   if (![annotation.title isEqualToString:@""]) {
      [theMapView addAnnotation:annotation];
   }
   [annotation release];
}

- (IBAction) showMore
{
   WHMoreViewController *vc = [[WHMoreViewController alloc] initWithNibName:@"WHMoreViewController" bundle:nil];
   vc.modalPresentationStyle = UIModalPresentationFormSheet;
   [self presentModalViewController:vc animated:YES];
   
}

#pragma mark MapViewDelegate

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
   [UIView beginAnimations:@"hourViews" context:nil];
   
   for (WHHourLayer *layer in hourLayers)
      [layer update:mapView forView:self.view];

   [UIView commitAnimations];
}

- (MKAnnotationView *)mapView:(MKMapView *)map viewForAnnotation:(id <MKAnnotation>)annotation
{
   static NSString *AnnotationViewID = @"annotationViewID";
   
   WHAnnotationView *annotationView = (WHAnnotationView *)[map dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
   if (annotationView == nil)
   {
      annotationView = [[[WHAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID] autorelease];
   }
   
   WHTimeAnnotation *whta = (WHTimeAnnotation *)annotation;
   annotationView.annotation = whta;
   annotationView.mapView = map;
   [annotationView setupCalloutView];
   annotationView.hour   = [whta hour];
   annotationView.minute = [whta minute];   
   [annotationView start];   

   return annotationView;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
   id <MKAnnotation> annotation = [[theMapView annotations] lastObject];
   [theMapView selectAnnotation:annotation animated:YES];
   WHAppDelegate *appDelegate = (WHAppDelegate *)[UIApplication sharedApplication].delegate;
   [appDelegate addLocation:annotation.coordinate];
}

#pragma mark UIGestureRecognizerDelegate

- (void) mapTapped:(UITapGestureRecognizer *)recognizer
{
   CGPoint point = [recognizer locationInView:theMapView];
   for (id <MKAnnotation> annotation in [theMapView annotations]) {
      // include the point?
      MKAnnotationView *av = [theMapView viewForAnnotation:annotation];
      CGPoint annotationPoint = [theMapView convertCoordinate:annotation.coordinate toPointToView:theMapView];
      CGRect boundingBox = CGRectMake(annotationPoint.x - av.frame.size.width/2,
                                      annotationPoint.y - av.frame.size.height/2,
                                      av.frame.size.width, av.frame.size.height);
      if (CGRectContainsPoint(boundingBox, point)) {
         NSLog(@"point included");
         [theMapView selectAnnotation:annotation animated:YES];
         return;
      }
   }
   CLLocationCoordinate2D coord = [theMapView convertPoint:point toCoordinateFromView:self.view];
   WHTimeAnnotation *annotation = [[WHTimeAnnotation alloc] initWithCoordinate:coord];
   [annotation search];
}

- (void) modeSwitched
{
   if (segmentedControl.selectedSegmentIndex == 0) {
      theMapView.mapType = MKMapTypeStandard;
      for (WHHourLayer *layer in hourLayers)
         [layer removeFromSuperlayer];
      [self showAnnotations];
   } else {
      theMapView.mapType = MKMapTypeSatellite;
      for (WHHourLayer *layer in hourLayers)
         [theMapView.layer addSublayer:layer];
      [self hideAnnotations];
   }
}

- (void) removeAnnotation:(NSNotification *)notification
{
   id <MKAnnotation> annotation = [[notification userInfo] objectForKey:@"annotation"];
   [theMapView removeAnnotation:annotation];
   WHAppDelegate *appDelegate = (WHAppDelegate *)[UIApplication sharedApplication].delegate;
   [appDelegate removeLocation:annotation.coordinate];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
   [UIView beginAnimations:@"hourViews" context:nil];
   
   for (WHHourLayer *layer in hourLayers)
      [layer update:theMapView forView:self.view];
   
   [UIView commitAnimations];
}

@end