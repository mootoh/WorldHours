//
//  WorldHoursViewController.h
//  WorldHours
//
//  Created by Motohiro Takayama on 3/20/10.
//  Copyright deadbeaf.org 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface WorldHoursViewController : UIViewController <MKMapViewDelegate, UIGestureRecognizerDelegate>
{
   IBOutlet MKMapView *theMapView;
   NSMutableArray *hourLayers;
   NSArray *colors;
}

@end