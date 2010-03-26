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
   enum {
      PARSE_STATE_INITIAL = 0,
      PARSE_STATE_TIMEZONE_ID,
      PARSE_STATE_GMT_OFFSET
   } state;

   NSString *timezoneId;
   NSString *gmtOffsetString;
   float gmtOffset;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSString *timezoneId;
@property (nonatomic, readonly) float gmtOffset;

- (id) initWithCoordinate:(CLLocationCoordinate2D) coord;
- (void) search;

- (NSInteger) hour;
- (NSInteger) minute;

@end