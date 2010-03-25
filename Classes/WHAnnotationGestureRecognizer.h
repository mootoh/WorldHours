//
//  Created by Motohiro Takayama on 3/25/10.
//  Copyright 2010 deadbeaf.org. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class WHTimeAnnotation;
@class OverlayLayer;

@interface WHAnnotationGestureRecognizer : UITapGestureRecognizer
{
   WHTimeAnnotation *annotation;
   MKMapView *mapView;
   UIView *rootView;
   CGPoint srcLocation, dstLocation;
   BOOL touching;
   OverlayLayer *overlayLayer;
}

- (void) setupOverlayLayer;

@property (nonatomic, assign) WHTimeAnnotation *annotation;
@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic, retain) UIView *rootView;

@end