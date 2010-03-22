//
//  WHTimeAnnotation.h
//  WorldHours
//
//  Created by Motohiro Takayama on 3/22/10.
//  Copyright 2010 deadbeaf.org. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface WHTimeAnnotation : NSObject <MKAnnotation>
{
   CLLocationCoordinate2D coordinate;
   NSXMLParser *parser;
   BOOL parsing;
   NSString *timezoneId;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSString *timezoneId;

- (id) initWithCoordinate:(CLLocationCoordinate2D) coord;

@end

