//
//  WorldHoursAppDelegate.m
//  WorldHours
//
//  Created by Motohiro Takayama on 3/20/10.
//  Copyright deadbeaf.org 2010. All rights reserved.
//

#import "WorldHoursAppDelegate.h"
#import "WorldHoursViewController.h"
#import "Reachability.h"

@implementation WorldHoursAppDelegate

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
   // write back the annotations
   [[NSUserDefaults standardUserDefaults] setObject:[locations allObjects] forKey:@"locations"];
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
   NSString *locationString = [NSString stringWithFormat:@"%f %f",
                               location.latitude, location.longitude];
   [locations addObject:locationString];
}

- (void) removeLocation:(CLLocationCoordinate2D)location
{
   NSString *locationString = [NSString stringWithFormat:@"%f %f",
                               location.latitude, location.longitude];
   [locations removeObject:locationString];
}

- (void)alertViewCancel:(UIAlertView *)alertView
{
}

@end