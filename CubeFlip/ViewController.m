//
//  ViewController.m
//  CubeFlip
//
//  Created by rollin.su on 12-01-30.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "RSCubeView.h"

@implementation ViewController
@synthesize cubeView;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView* contentView = [[[UIView alloc] initWithFrame:self.cubeView.bounds] autorelease];
    contentView.backgroundColor = [UIColor orangeColor];
    [self.cubeView setContentView:contentView];
}

- (void)viewDidUnload
{
    [self setCubeView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void)dealloc {
    [cubeView release];
    [super dealloc];
}
- (IBAction)onButtonTapped:(id)sender {
    
    //Alternate between the 2 prototype views
    UIView* nextView = [[[UIView alloc] initWithFrame:self.cubeView.bounds] autorelease];
    nextView.backgroundColor = [UIColor orangeColor];
    
    NSInteger tag = ((UIButton*)sender).tag;
    RSCubeViewRotationDirection direction;
    if (tag == 1) {
        direction = RSCubeViewRotationDirectionUp;
    } else if (tag == 2) {
        direction = RSCubeViewRotationDirectionDown;
    } else if (tag == 3) {
        direction = RSCubeViewRotationDirectionLeft;
    } else {
        direction = RSCubeViewRotationDirectionRight;
    }
    
    [self.cubeView rotateToView:nextView direction:direction duration:.6f];
}
@end
