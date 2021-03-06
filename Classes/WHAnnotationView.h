//
//  WHAnnotationView.h
//  WorldHours
//
//  Created by Motohiro Takayama on 3/25/10.
//  Copyright 2010 deadbeaf.org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class WHTimeAnnotation;

@interface WHAnnotationLeftCalloutView : UIView
{
   MKMapView *mapView;
}

@property (nonatomic, retain) MKMapView *mapView;

- (void) setupGestureRecognizer:(WHTimeAnnotation *)annotation;

@end

@interface WHAnnotationRightCalloutView : UIView
{
   WHTimeAnnotation *annotation;
}

@property (nonatomic, retain) WHTimeAnnotation *annotation;

@end


@interface WHAnnotationView : MKAnnotationView <UIGestureRecognizerDelegate>
{
   NSInteger hour;
   NSInteger minute;
   CGFloat frequency; // update frequency, specified in second
   BOOL working;
   BOOL calculatingDifference;
   MKMapView *mapView;
   
   enum {
      STATE_INITIAL = 0,
      STATE_CALLOUT = 1
   } state;
}

@property (nonatomic, assign) NSInteger hour;
@property (nonatomic, assign) NSInteger minute;
@property (nonatomic, assign) CGFloat frequency;
@property (nonatomic, readonly) BOOL working;
@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic, assign) BOOL calculatingDifference;

- (void) setupCalloutView;

- (void) start;
- (void) stop;

@end