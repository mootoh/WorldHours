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

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
       self.userInteractionEnabled = NO;
    }
    return self;
}

- (void) update:(MKMapView *)mapView forView:(UIView *)view
{
   CLLocationCoordinate2D center = {
      0,
      location.longitude};// + 15.0/2.0};
   NSLog(@"center = %f, %f", center.latitude, center.longitude);
   MKCoordinateRegion region = {center, {179.9, 15.0}};
   CGRect rect = [mapView convertRegion:region toRectToView:mapView];
   self.frame = rect;
   NSLog(@"HV rect = (%f, %f), (%f, %f)", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc {
    [super dealloc];
}


@end