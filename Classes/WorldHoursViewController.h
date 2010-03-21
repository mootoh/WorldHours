//
//  WorldHoursViewController.h
//  WorldHours
//
//  Created by Motohiro Takayama on 3/20/10.
//  Copyright deadbeaf.org 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


@interface VerticalView : UIView
@end

@interface WorldHoursViewController : UIViewController <MKMapViewDelegate>
{
   IBOutlet MKMapView *theMapView;
   NSMutableSet *hourViews;
}

@end