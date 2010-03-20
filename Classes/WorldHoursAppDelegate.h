//
//  WorldHoursAppDelegate.h
//  WorldHours
//
//  Created by Motohiro Takayama on 3/20/10.
//  Copyright deadbeaf.org 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WorldHoursViewController;

@interface WorldHoursAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    WorldHoursViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet WorldHoursViewController *viewController;

@end

