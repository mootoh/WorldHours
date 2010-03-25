//
//  HourLayer.m
//  WorldHours
//
//  Created by Motohiro Takayama on 3/22/10.
//  Copyright 2010 deadbeaf.org. All rights reserved.
//

#import "WHHourLayer.h"
#import <QuartzCore/QuartzCore.h>

@implementation WHHourLayer
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

- (void) update:(MKMapView *)mapView forView:(UIView *)view
{
   CLLocationCoordinate2D center = {0, location.longitude + 15.0/2.0};
   MKCoordinateRegion region = {center, {179.9999, 14.9999999}};
   CGRect rect = [mapView convertRegion:region toRectToView:mapView];
   CGFloat x = rect.origin.x, y = rect.origin.y, w = rect.size.width, h = rect.size.height;
   const CGFloat x0 = mapView.frame.origin.x, y0 = mapView.frame.origin.y;
   const CGFloat xx = mapView.frame.origin.x + mapView.frame.size.width;
   const CGFloat yy = mapView.frame.origin.y + mapView.frame.size.height;

   BOOL clipping = NO;
   if (x < x0) {
      if (x+w <= x0) {
         clipping = YES;
         x = -1.0;
         y = -1.0;
         w = 0.1;
         h = 0.1;
      } else {
         w = w + x;
         x = x0;
      }
   } else if (x >= xx) {
      clipping = YES;
      x = -1.0;
      y = -1.0;
      w = 0.1;
      h = 0.1;
   } else if (x      < xx &&
              x + w >= xx) {
      w = xx-x;
   }
   
   if (y < y0) {
      if (y+h <= y0) {
         clipping = YES;
         x = -1.0;
         y = -1.0;
         w = 0.1;
         h = 0.1;
      } else {
         h = h + y;
         y = y0;
      }
   } else if (y >= yy) {
      clipping = YES;
      x = -1.0;
      y = -1.0;
      w = 0.1;
      h = 0.1;
   } else if (y      < yy &&
              y + h >= yy) {
      h = yy-y;
   }
   
   if (w > mapView.frame.size.width)
      w = mapView.frame.size.width;
   if (h > mapView.frame.size.height)
      h = mapView.frame.size.height;

   rect = CGRectMake(x, y, w, h);

   self.frame = rect;
   if (! clipping)
      [self setNeedsDisplay];
}

- (void)drawInContext:(CGContextRef)context
{
   CGRect rect = self.frame;
   
   CGColorRef color = [[[WHHourLayer colors] objectAtIndex:hour] CGColor];
   CGContextSetStrokeColorWithColor(context, color);
   
   CGFloat lineWidth = rect.size.width*2;
   CGContextSetLineWidth(context, lineWidth);
   
   CGContextMoveToPoint(context, 0.0f, 0.0f);
   CGContextAddLineToPoint(context, 0.0f, rect.size.height);
   CGContextStrokePath(context);   

#ifndef SHOW_HOUR_TEXT
   if (hour % 3 == 0) {
      CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
      CGContextSelectFont(context, "Helvetica", 14.0, kCGEncodingMacRoman);
      NSString *hourString = [NSString stringWithFormat:@"%d", hour];
      CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0, -1.0));
      CGContextShowTextAtPoint(context, 10.0, 14.0, [hourString UTF8String], [hourString lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
   }
#endif // SHOW_HOUR_TEXT
}

@end