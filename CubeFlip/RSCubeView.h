//
//  RSCubeView.h
//  
//
//  Created by rollin.su on 12-01-24.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

//Direction of the cube rotate effect
typedef enum {
    RSCubeViewRotationDirectionDown,
    RSCubeViewRotationDirectionUp,
    RSCubeViewRotationDirectionLeft,
    RSCubeViewRotationDirectionRight
} RSCubeViewRotationDirection;

typedef enum {
    RSCubeViewFadeOptionNone,
    RSCubeViewFadeOptionDarken,
    RSCubeViewFadeOptionLighten,
    RSCubeViewFadeOptionFadeOut
} RSCubeViewFadeOption;


@interface RSCubeView : UIView

@property (nonatomic, retain) IBOutlet UIView* contentView;
@property (nonatomic, assign) CGFloat focalLength;

-(void)rotateToView:(UIView*)aView direction:(RSCubeViewRotationDirection)aDirection;
-(void)rotateToView:(UIView*)aView direction:(RSCubeViewRotationDirection)aDirection duration:(CGFloat)aDuration fadeOption:(RSCubeViewFadeOption)fadeOption;

@end
