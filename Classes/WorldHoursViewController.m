//
//  WorldHoursViewController.m
//  WorldHours
//
//  Created by Motohiro Takayama on 3/20/10.
//  Copyright deadbeaf.org 2010. All rights reserved.
//

#import "WorldHoursViewController.h"
#import "HourView.h"

@interface WHTimeAnnotation : NSObject <MKAnnotation>
{
   CLLocationCoordinate2D coordinate;
   NSXMLParser *parser;
   BOOL parsing;
   NSString *timezoneId;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSString *timezoneId;

- (id) initWithCoordinate:(CLLocationCoordinate2D) coord;

@end

@implementation WHTimeAnnotation
@synthesize coordinate;
@synthesize timezoneId;

// thanks to http://www.geonames.org/export/web-services.html#timezone
#define kTimeZoneWebServiceURL @"http://ws.geonames.org/timezone?"

- (id) initWithCoordinate:(CLLocationCoordinate2D) coord
{
   if (self = [super init]) {
      coordinate = coord;
      parsing = NO;
      timezoneId = @"";
      NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@lat=%f&lng=%f",
                                         kTimeZoneWebServiceURL, coord.latitude, coord.longitude]];
      parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
      parser.delegate = self;
      [parser parse];
   }
   return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
   if ([elementName isEqualToString:@"timezoneId"])
      parsing = YES;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
   if ([elementName isEqualToString:@"timezoneId"])
      parsing = NO;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
   if (parsing)
      self.timezoneId = [timezoneId stringByAppendingString:string];
}

- (NSString *)title
{
   return timezoneId;
}

- (NSString *) subtitle
{
   NSCalendar *calendar = [NSCalendar currentCalendar];
   NSTimeZone *gmtTimeZone = [NSTimeZone timeZoneWithName:timezoneId];
   [calendar setTimeZone:gmtTimeZone];
   
   NSDateComponents *compo = [calendar components:NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:[NSDate date]];
   NSInteger hour = [compo hour];
   NSInteger min = [compo minute];
   return [NSString stringWithFormat:@"%02d:%02d", hour, min];
}

- (void) dealloc
{
   [parser release];
   [super dealloc];
}

@end

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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
   [super viewDidLoad];
   hourViews = [[NSMutableSet alloc] init];

   MKCoordinateRegion nextCenter = {{40, 0}, {150, 360}};
   theMapView.region = nextCenter;
   
   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tapped:) name:@"tapped" object:nil];
   
   UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
   [theMapView addGestureRecognizer:tapGR];
   tapGR.delegate = self;
   [tapGR release];
   
   NSLog(@"%@", [NSTimeZone knownTimeZoneNames]);
   NSLog(@"%@", [NSTimeZone abbreviationDictionary]);

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
   for (HourView *hv in hourViews)
      [hv update:mapView forView:self.view];
   [UIView commitAnimations];
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