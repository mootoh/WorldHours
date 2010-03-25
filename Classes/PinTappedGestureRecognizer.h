//
//  Created by Motohiro Takayama on 3/25/10.
//  Copyright 2010 deadbeaf.org. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface PinTappedGestureRecognizer : UITapGestureRecognizer
{
   id <MKAnnotation> annotation;
}

@property (nonatomic, assign) id <MKAnnotation> annotation;
@end