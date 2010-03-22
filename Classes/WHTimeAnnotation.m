//
//  WHTimeAnnotation.m
//  WorldHours
//
//  Created by Motohiro Takayama on 3/22/10.
//  Copyright 2010 deadbeaf.org. All rights reserved.
//

#import "WHTimeAnnotation.h"

@implementation WHTimeAnnotation
@synthesize coordinate;
@synthesize timezoneId;

// thanks to http://www.geonames.org/export/web-services.html#timezone
#define kTimeZoneWebServiceURL @"http://ws.geonames.org/timezone?"

- (id) initWithCoordinate:(CLLocationCoordinate2D) coord
{
   if (self = [super init]) {
      coordinate = coord;
      parsing = NO;
      timezoneId = @"";
      NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@lat=%f&lng=%f",
                                         kTimeZoneWebServiceURL, coord.latitude, coord.longitude]];
      parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
      parser.delegate = self;
      [parser parse];
   }
   return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
   if ([elementName isEqualToString:@"timezoneId"])
      parsing = YES;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
   if ([elementName isEqualToString:@"timezoneId"])
      parsing = NO;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
   if (parsing)
      self.timezoneId = [timezoneId stringByAppendingString:string];
}

- (NSString *)title
{
   return timezoneId;
}

- (NSString *) subtitle
{
   NSCalendar *calendar = [NSCalendar currentCalendar];
   NSTimeZone *gmtTimeZone = [NSTimeZone timeZoneWithName:timezoneId];
   [calendar setTimeZone:gmtTimeZone];
   
   NSDateComponents *compo = [calendar components:NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:[NSDate date]];
   NSInteger hour = [compo hour];
   NSInteger min = [compo minute];
   return [NSString stringWithFormat:@"%02d:%02d", hour, min];
}

- (void) dealloc
{
   [parser release];
   [super dealloc];
}

@end