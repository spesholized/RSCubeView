//
//  RSCubeView.m
//  
//
//  Created by rollin.su on 12-01-24.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RSCubeView.h"
#import <QuartzCore/QuartzCore.h>

#define kFlipAnimationKey @"FlipAnimation"
#define kFadeOutAnimationKey @"FadeOutAnimation"
#define kFadeInAnimationKey @"FadeInAnimation"
#define kOpacityVisible 1.f
#define kOpacityFaded 0.1f
#define kDefaultFocalLength 800.f

@interface RSCubeView()
@property (nonatomic, assign) BOOL isTransitioning;
@property (nonatomic, retain) UIView* nextView;
@property (nonatomic, retain) CALayer* transformLayer;
@property (nonatomic, retain) CALayer* fadeOutLayer;
@property (nonatomic, retain) CALayer* fadeInLayer;

-(id)captureView:(UIView*)view;
-(CALayer*)makeSurface:(CATransform3D)t withView:(UIView *)aNewView;
-(void)moveFrom:(RSCubeViewRotationDirection)aDirection duration:(float)aDuration;
@end

@implementation RSCubeView
@synthesize contentView;
@synthesize isTransitioning;
@synthesize nextView;
@synthesize transformLayer;
@synthesize fadeOutLayer;
@synthesize fadeInLayer;
@synthesize focalLength;

-(id)init
{
    self = [super init];
    if (self) {
        focalLength = kDefaultFocalLength;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        focalLength = kDefaultFocalLength;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        focalLength = kDefaultFocalLength;
    }
    return self;
}

-(void)dealloc
{
    [contentView release];
    [nextView release];
    [fadeOutLayer release];
    [fadeInLayer release];
    [transformLayer release];
    [super dealloc];
}

#pragma mark - Graphics Helper Methods
//Transition preparation for Cube effect
- (id) captureView:(UIView*)view {
    UIGraphicsBeginImageContext(view.frame.size);
	[view.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    return (id) [newImage CGImage];
}

- (CALayer*) makeSurface:(CATransform3D)t withView:(UIView *)aNewView{
    CGRect rect = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    
    CALayer *imageLayer = [CALayer layer];
    imageLayer.anchorPoint = CGPointMake(1, 1);
    imageLayer.frame = rect;
    imageLayer.transform = t;  
    imageLayer.contents = [self captureView:aNewView];
    return imageLayer;
}

-(void)moveFrom:(RSCubeViewRotationDirection)aDirection duration:(float)aDuration
{
    [CATransaction flush];
    CABasicAnimation *rotation;
    CABasicAnimation *translation;
    CABasicAnimation *translationZ;
    CAAnimationGroup *group = [CAAnimationGroup animation]; 
    group.delegate = self; 
    group.duration = aDuration;
    group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    if (aDirection == RSCubeViewRotationDirectionDown)
    {
        translation = [CABasicAnimation animationWithKeyPath:@"sublayerTransform.translation.y"];
        translation.toValue = [NSNumber numberWithFloat:(self.bounds.size.height / 2)];
        rotation = [CABasicAnimation animationWithKeyPath:@"sublayerTransform.rotation.x"]; 
        rotation.toValue = [NSNumber numberWithFloat:-M_PI_2];
        translationZ = [CABasicAnimation animationWithKeyPath:@"sublayerTransform.translation.z"];
        translationZ.toValue = [NSNumber numberWithFloat:-(self.bounds.size.height / 2)];
    } else if (aDirection == RSCubeViewRotationDirectionUp) {
        translation = [CABasicAnimation animationWithKeyPath:@"sublayerTransform.translation.y"];
        translation.toValue = [NSNumber numberWithFloat:-(self.bounds.size.height / 2)];
        rotation = [CABasicAnimation animationWithKeyPath:@"sublayerTransform.rotation.x"]; 
        rotation.toValue = [NSNumber numberWithFloat:M_PI_2];
        translationZ = [CABasicAnimation animationWithKeyPath:@"sublayerTransform.translation.z"];
        translationZ.toValue = [NSNumber numberWithFloat:-(self.bounds.size.height / 2)];
    } else if (aDirection == RSCubeViewRotationDirectionLeft) {
        translation = [CABasicAnimation animationWithKeyPath:@"sublayerTransform.translation.x"];
        translation.toValue = [NSNumber numberWithFloat:-(self.bounds.size.width / 2)];
        rotation = [CABasicAnimation animationWithKeyPath:@"sublayerTransform.rotation.y"]; 
        rotation.toValue = [NSNumber numberWithFloat:-M_PI_2];
        translationZ = [CABasicAnimation animationWithKeyPath:@"sublayerTransform.translation.z"];
        translationZ.toValue = [NSNumber numberWithFloat:-(self.bounds.size.width / 2)];
    } else {
        translation = [CABasicAnimation animationWithKeyPath:@"sublayerTransform.translation.x"];
        translation.toValue = [NSNumber numberWithFloat:(self.bounds.size.width / 2)];
        rotation = [CABasicAnimation animationWithKeyPath:@"sublayerTransform.rotation.y"]; 
        rotation.toValue = [NSNumber numberWithFloat:M_PI_2];
        translationZ = [CABasicAnimation animationWithKeyPath:@"sublayerTransform.translation.z"];
        translationZ.toValue = [NSNumber numberWithFloat:-(self.bounds.size.width / 2)];
    }
    
    CABasicAnimation* fadeOut = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeOut.toValue = [NSNumber numberWithFloat:kOpacityFaded];
    fadeOut.fillMode = kCAFillModeForwards;
    fadeOut.removedOnCompletion = NO;
    fadeOut.duration = aDuration;
    fadeOut.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CABasicAnimation* fadeIn = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeIn.toValue = [NSNumber numberWithFloat:kOpacityVisible];
    fadeIn.fillMode = kCAFillModeForwards;
    fadeIn.removedOnCompletion = NO;
    fadeIn.duration = aDuration;
    fadeIn.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    group.animations = [NSArray arrayWithObjects: rotation, translation, translationZ, nil];
    group.fillMode = kCAFillModeForwards; 
    group.removedOnCompletion = NO;
    
    [CATransaction begin];
    [transformLayer addAnimation:group forKey:kFlipAnimationKey];
    //[fadeOutLayer addAnimation:fadeOut forKey:kFadeOutAnimationKey];
    //[fadeInLayer addAnimation:fadeIn forKey:kFadeInAnimationKey];
    [CATransaction commit];
}

-(void)setContentView:(UIView *)aContentView
{
    [contentView autorelease];
    [contentView removeFromSuperview];
    
    contentView = [aContentView retain];
    [self addSubview:contentView];
}


-(void)rotateToView:(UIView*)aView direction:(RSCubeViewRotationDirection)aDirection
{
    [self rotateToView:aView direction:aDirection duration:0.3f fadeOption:RSCubeViewFadeOptionDarken];
}

-(void)rotateToView:(UIView *)aView direction:(RSCubeViewRotationDirection)aDirection duration:(CGFloat)aDuration fadeOption:(RSCubeViewFadeOption)fadeOption
{
    /*
     Overview of steps:
     1) Capture current visible view and draw into a CALayer
     2) Draw the new view's content into a sublayer
     3) Position the layers
     4) Animate the layers
     5) Replace view with new content
     */
    
    if (isTransitioning || aView == nil) {
        return;
    }
    
    if (aView.superview != nil) {
        [aView removeFromSuperview];
    }
    
    self.nextView = aView;
    
    //Construct transform layer
    self.transformLayer = [CALayer layer];
    transformLayer.frame = self.bounds;
    
    //Make sublayer transform. All sublayers will have this transform
    CATransform3D sublayerTransform = CATransform3DIdentity;
    
    sublayerTransform.m34 = 1.0 / - self.focalLength; //perspective
    [transformLayer setSublayerTransform:sublayerTransform];
    
    [self.layer addSublayer:transformLayer];
    
    //Init Fade-out layer. This is the surface that will disappear
    CATransform3D t = CATransform3DMakeTranslation(0.f, 0.f, 0.f);
    self.fadeOutLayer = [self makeSurface:t withView:contentView];
    [transformLayer addSublayer:self.fadeOutLayer];
    contentView.hidden = YES;
    
    //Init the Fade-In Layer. This is the surface that will appear next
    if (aDirection == RSCubeViewRotationDirectionDown) {
        //The order of applying these transforms matter since makeSurface: sets the anchor point to (1,1)
        t = CATransform3DTranslate(t, 0, -self.bounds.size.height, 0);
        t = CATransform3DRotate(t, M_PI_2, 1, 0, 0);
    } else if (aDirection == RSCubeViewRotationDirectionUp) {
        t = CATransform3DRotate(t, -M_PI_2, 1, 0, 0);
        t = CATransform3DTranslate(t, 0, self.bounds.size.height, 0);
    } else if (aDirection == RSCubeViewRotationDirectionLeft) {
        t = CATransform3DRotate(t, M_PI_2, 0, 1, 0);
        t = CATransform3DTranslate(t, self.bounds.size.width, 0, 0);
    } else {
        t = CATransform3DTranslate(t, -self.bounds.size.width, 0, 0);
        t = CATransform3DRotate(t, -M_PI_2, 0, 1, 0);
    }
    
    self.fadeInLayer = [self makeSurface:t withView:aView];
    //self.fadeInLayer.opacity = kOpacityFaded;
    [transformLayer addSublayer:self.fadeInLayer];
    
    [self moveFrom:aDirection duration:aDuration];
}

#pragma mark - Animation Delegate

- (void)animationDidStart:(CAAnimation *)animation {
	
	isTransitioning = YES;
    [contentView removeFromSuperview];
    [contentView setHidden:NO];
}

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)finished {
	
	isTransitioning = NO;
    nextView.frame = contentView.frame;
    self.contentView = nextView;
    
    [transformLayer removeFromSuperlayer];
    self.fadeOutLayer = nil;
    self.fadeInLayer = nil;
    self.transformLayer = nil;
    nextView = nil;
}

@end
