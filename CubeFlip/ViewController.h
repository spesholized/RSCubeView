//
//  ViewController.h
//  CubeFlip
//
//  Created by rollin.su on 12-01-30.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RSCubeView;
@interface ViewController : UIViewController

@property (retain, nonatomic) IBOutlet RSCubeView *cubeView;
- (IBAction)onButtonTapped:(id)sender;
@end
