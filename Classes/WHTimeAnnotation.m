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
@synthesize gmtOffset;

// thanks to http://www.geonames.org/export/web-services.html#timezone
#define kTimeZoneWebServiceURL @"http://ws.geonames.org/timezone?"

- (id) initWithCoordinate:(CLLocationCoordinate2D) coord
{
   if (self = [super init]) {
      coordinate = coord;
      state = PARSE_STATE_INITIAL;
      timezoneId = @"";
      gmtOffsetString = @"";
      gmtOffset = 0.0;

      NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@lat=%f&lng=%f",
                                         kTimeZoneWebServiceURL, coord.latitude, coord.longitude]];
      parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
      parser.delegate = self;
   }
   return self;
}

- (void) search
{
   [parser parse];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
   if ([elementName isEqualToString:@"timezoneId"])
      state = PARSE_STATE_TIMEZONE_ID;
   else if ([elementName isEqualToString:@"gmtOffset"])
      state = PARSE_STATE_GMT_OFFSET;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
   if ([elementName isEqualToString:@"timezoneId"])
      state = PARSE_STATE_INITIAL;
   else if ([elementName isEqualToString:@"gmtOffset"]) {
      gmtOffset = [gmtOffsetString floatValue];
      state = PARSE_STATE_INITIAL;
   }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
   if (state == PARSE_STATE_TIMEZONE_ID)
      self.timezoneId = [timezoneId stringByAppendingString:string];
   else if (state == PARSE_STATE_GMT_OFFSET)
      gmtOffsetString = [gmtOffsetString stringByAppendingString:string];
}

- (void) parserDidEndDocument:(NSXMLParser *)parser
{
   [[NSNotificationCenter defaultCenter] postNotificationName:@"parseFinished" object:nil userInfo:[NSDictionary dictionaryWithObject:self forKey:@"annotation"]];
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

- (NSInteger) hour
{
   NSCalendar *calendar = [NSCalendar currentCalendar];
   NSTimeZone *gmtTimeZone = [NSTimeZone timeZoneWithName:timezoneId];
   [calendar setTimeZone:gmtTimeZone];
   
   NSDateComponents *compo = [calendar components:NSHourCalendarUnit fromDate:[NSDate date]];
   return [compo hour];
}

- (NSInteger) minute
{
   NSCalendar *calendar = [NSCalendar currentCalendar];
   NSTimeZone *gmtTimeZone = [NSTimeZone timeZoneWithName:timezoneId];
   [calendar setTimeZone:gmtTimeZone];
   
   NSDateComponents *compo = [calendar components:NSMinuteCalendarUnit fromDate:[NSDate date]];
   return [compo minute];
}

@end