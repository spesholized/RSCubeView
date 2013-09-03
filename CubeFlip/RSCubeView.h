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



@interface RSCubeView : UIView

@property (nonatomic, strong) IBOutlet UIView* contentView;
@property (nonatomic, assign) CGFloat focalLength;
@property (nonatomic, assign) BOOL fillContentViewToBounds;

-(void)rotateToView:(UIView*)aView direction:(RSCubeViewRotationDirection)aDirection duration:(NSTimeInterval)aDuration;

@end //RSCubeView


@protocol RSCubeViewDelegate <NSObject>

-(void)cubeView:(RSCubeView*)cubeView didSwipeInDirection:(RSCubeViewRotationDirection)direction;

@end
