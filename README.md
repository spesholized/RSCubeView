RSCubeView
=============

RSCubeView lets you apply 3D rotation effect to a UIView.

###Usage
-Add `QuartzCore.framework` into your XCode project

-Copy `RSCubeView.h` and `RSCubeView.m` under the `CubeFlip/` folder to your project

-Put `#import RSCubeView.h` in your source files to start using.

###Example Project
Open `CubeFlip.xcodeproj` in XCode to immediately see RSCubeView in action.

###Example Code
    //Perform a 3D rotation on a UIView with a red background to a UIView with a blue background
    
    CGRect rect = CGRectMake(0.f, 0.f, 200.f, 200.f);
    
    RSCubeView* cube = [[[RSCubeView alloc] initWithFrame:rect] autorelease];
    [self.view addSubview:cube]; //Add as a subview to your main view
        
    UIView* redView = [[[UIView alloc] initWithFrame:rect] autorelease];
    redView.backgroundColor = [UIColor redColor];
        
    UIView* blueView = [[[UIView alloc] initWithFrame:rect] autorelease];
    blueView.backgroundColor = [UIColor blueColor];
        
    cube.contentView = redView;
    [cube rotateToView:blueView direction:RSCubeViewRotationDirectionDown duration:1.f];
    
