//
//  HourLayer.h
//  WorldHours
//
//  Created by Motohiro Takayama on 3/22/10.
//  Copyright 2010 deadbeaf.org. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <MapKit/MapKit.h>

@interface HourLayer : CALayer {
   CLLocationCoordinate2D location;
   NSInteger offset;
   NSInteger hour;   
}

@property (nonatomic, assign) CLLocationCoordinate2D location;
@property (nonatomic, assign) NSInteger offset;
@property (nonatomic, assign) NSInteger hour;

- (void) update:(MKMapView *)mapView forView:(UIView *)view;

@end