//
//  WorldHoursViewController.m
//  WorldHours
//
//  Created by Motohiro Takayama on 3/20/10.
//  Copyright deadbeaf.org 2010. All rights reserved.
//

#import "WorldHoursViewController.h"

@implementation WorldHoursViewController


/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
   [super viewDidLoad];
   
   for (int i=0; i<24; i++) {
      UIView *v = [[UIView alloc] initWithFrame:CGRectMake(i*self.view.frame.size.height/24.0f, 0, self.view.frame.size.height/24, self.view.frame.size.width)];
      CGFloat colorFactor = (CGFloat)i / 24.0f;
      v.backgroundColor = [UIColor colorWithRed:colorFactor green:colorFactor blue:colorFactor alpha:0.7];
      [mapView addSubview:v];
      [v release];
   }
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

@end
