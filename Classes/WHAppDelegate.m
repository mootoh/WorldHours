//
//  WorldHoursAppDelegate.m
//  WorldHours
//
//  Created by Motohiro Takayama on 3/20/10.
//  Copyright deadbeaf.org 2010. All rights reserved.
//

#import "WHAppDelegate.h"
#import "WorldHoursViewController.h"
#import "Reachability.h"
#import "WHTimeAnnotation.h"

@implementation WHAppDelegate

@synthesize window;
@synthesize viewController;
@synthesize locations;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
   if ([[Reachability sharedReachability] internetConnectionStatus] == NotReachable) {
      UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Turn Off Airplane Mode or Use Wi-Fi to Access Data" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
      [alertView show];
      return YES;
   }
   self.locations = [NSMutableSet setWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:@"locations"]];
   [window addSubview:viewController.view];
   [window makeKeyAndVisible];

	return YES;
}

- (void) applicationWillTerminate:(UIApplication *)application
{
   NSMutableSet *locs = [NSMutableSet set];
   for (WHTimeAnnotation *annotation in viewController.annotations) {
      CLLocationCoordinate2D location = annotation.coordinate;
      NSString *locationString = [NSString stringWithFormat:@"%.5f %.5f",
                                  location.latitude, location.longitude];
      [locs addObject:locationString];
   }
   
   // write back the annotations
   [[NSUserDefaults standardUserDefaults] setObject:[locs allObjects] forKey:@"locations"];
   
   [[NSUserDefaults standardUserDefaults] setInteger:viewController.segmentedControl.selectedSegmentIndex forKey:@"mapMode"];
}

- (void)dealloc
{
   [locations release];
   [viewController release];
   [window release];
   [super dealloc];
}

- (void) addLocation:(CLLocationCoordinate2D)location
{
   NSString *locationString = [NSString stringWithFormat:@"%.5f %.5f",
                               location.latitude, location.longitude];

   for (NSString *str in locations)
      if ([str isEqualToString:locationString])
         return;

   [locations addObject:locationString];
}

- (void) removeLocation:(CLLocationCoordinate2D)location
{
   NSString *locationString = [NSString stringWithFormat:@"%.5f %.5f",
                               location.latitude, location.longitude];

   NSString *target = nil;
   for (NSString *str in locations)
      if ([str isEqualToString:locationString])
         target = [str copy];

   if (target)
      [locations removeObject:target];
}

@end