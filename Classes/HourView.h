//
//  HourView.h
//  WorldHours
//
//  Created by Motohiro Takayama on 3/21/10.
//  Copyright 2010 deadbeaf.org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface HourView : UIView
{
   CLLocationCoordinate2D location;
   NSInteger offset;
   NSInteger hour;
}

@property (nonatomic, assign) CLLocationCoordinate2D location;
@property (nonatomic, assign) NSInteger offset;
@property (nonatomic, assign) NSInteger hour;

- (void) update:(MKMapView *)mapView forView:(UIView *)view;

@end