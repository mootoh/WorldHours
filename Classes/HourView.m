//
//  HourView.m
//  WorldHours
//
//  Created by Motohiro Takayama on 3/21/10.
//  Copyright 2010 deadbeaf.org. All rights reserved.
//

#import "HourView.h"

@implementation HourView
@synthesize location;
@synthesize offset;
@synthesize hour;

static NSArray *s_colors = nil;

+ (NSArray *) colors
{
   if (s_colors == nil) {
      s_colors = [NSArray arrayWithObjects:
                [UIColor colorWithRed:0.20 green:0.20 blue:0.20 alpha:0.5], // AM 0
                [UIColor colorWithRed:0.25 green:0.25 blue:0.25 alpha:0.5],
                [UIColor colorWithRed:0.30 green:0.30 blue:0.30 alpha:0.5],
                [UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:0.5],
                [UIColor colorWithRed:0.40 green:0.40 blue:0.40 alpha:0.5],
                [UIColor colorWithRed:0.45 green:0.45 blue:0.45 alpha:0.5], // AM 5, good morning
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
                [UIColor colorWithRed:0.50 green:0.50 blue:0.50 alpha:0.3], // PM 6, night begins
                [UIColor colorWithRed:0.45 green:0.45 blue:0.45 alpha:0.4],
                
                [UIColor colorWithRed:0.40 green:0.40 blue:0.40 alpha:0.4],
                [UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:0.5],
                [UIColor colorWithRed:0.30 green:0.30 blue:0.30 alpha:0.5],
                [UIColor colorWithRed:0.25 green:0.25 blue:0.25 alpha:0.5],
                nil];
      [s_colors retain];
   }
   return s_colors;
}

- (id)initWithFrame:(CGRect)frame
{
   if ((self = [super initWithFrame:frame])) {
      // Initialization code
      self.userInteractionEnabled = NO;
      self.backgroundColor = [UIColor clearColor];
   }
   return self;
}

- (void) update:(MKMapView *)mapView forView:(UIView *)view
{
   CLLocationCoordinate2D center = {0, location.longitude + 15.0/2.0};
   MKCoordinateRegion region = {center, {170.0, 14.9999999}};
   CGRect rect = [mapView convertRegion:region toRectToView:mapView];
   NSLog(@"updating rect = %f, %f, %f, %f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
   self.frame = rect;
}

- (void)drawRect:(CGRect)rect
{
   NSLog(@"drawRect");
   CGContextRef context = UIGraphicsGetCurrentContext();
   CGColorRef color = [[[HourView colors] objectAtIndex:hour] CGColor];
   CGContextSetStrokeColorWithColor(context, color);
   
   CGFloat lineWidth = rect.size.width*2;
   CGContextSetLineWidth(context, lineWidth);
   
   CGContextMoveToPoint(context, 0.0f, 0.0f);
   CGContextAddLineToPoint(context, 0.0f, rect.size.height);
   CGContextStrokePath(context);   

   CGContextSetFillColorWithColor(context, [[UIColor blackColor] CGColor]);
   NSLog(@"rect = %f, %f, %f, %f",
         rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
   CGRect textRect = rect;
   [[NSString stringWithFormat:@"%d", hour] drawInRect:textRect withFont:[UIFont systemFontOfSize:12]];   
}

- (void)dealloc
{
   [super dealloc];
}

@end