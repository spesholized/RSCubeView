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
#define kOpacityTranslucent 0.5f
#define kOpacityInvisible 0.0f
#define kDefaultFocalLength 800.f

@interface RSCubeView()
@property (nonatomic, assign) BOOL isTransitioning;
@property (nonatomic, retain) UIView* nextView;
@property (nonatomic, retain) CALayer* transformLayer;
@property (nonatomic, retain) CALayer* fadeOutLayer;
@property (nonatomic, retain) CALayer* fadeOutMaskLayer;
@property (nonatomic, retain) CALayer* fadeInLayer;
@property (nonatomic, retain) CALayer* fadeInMaskLayer;

-(CALayer*)layerFromView:(UIView*)aView withTransform:(CATransform3D)transform;
-(void)moveFrom:(RSCubeViewRotationDirection)aDirection duration:(float)aDuration;
@end

@implementation RSCubeView
@synthesize contentView;
@synthesize isTransitioning;
@synthesize nextView;
@synthesize transformLayer;
@synthesize fadeOutLayer;
@synthesize fadeOutMaskLayer;
@synthesize fadeInLayer;
@synthesize fadeInMaskLayer;
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
    [fadeOutMaskLayer release];
    [fadeInLayer release];
    [fadeInMaskLayer release];
    [transformLayer release];
    [super dealloc];
}

#pragma mark - Graphics Helper Methods
- (CALayer*) layerFromView:(UIView*)aView withTransform:(CATransform3D)transform
{
    CGRect rect = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    
    CALayer *imageLayer = [CALayer layer];
    imageLayer.anchorPoint = CGPointMake(1, 1);
    imageLayer.frame = rect;
    imageLayer.transform = transform;
    
    //Capture View
    UIGraphicsBeginImageContext(aView.frame.size);
	[aView.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    
    imageLayer.contents = (id) newImage.CGImage;
    return imageLayer; 
}
-(void)moveFrom:(RSCubeViewRotationDirection)aDirection duration:(float)aDuration
{
    [CATransaction flush];
    CABasicAnimation *rotation;
    CABasicAnimation *translation;
    CABasicAnimation *translationZ;
    CABasicAnimation* fadeOut = [CABasicAnimation animationWithKeyPath:@"opacity"];
    CABasicAnimation* fadeIn = [CABasicAnimation animationWithKeyPath:@"opacity"];
    
    fadeOut.fillMode = kCAFillModeForwards;
    fadeOut.removedOnCompletion = NO;
    fadeOut.duration = aDuration;
    fadeOut.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    fadeIn.fillMode = kCAFillModeForwards;
    fadeIn.removedOnCompletion = NO;
    fadeIn.duration = aDuration;
    fadeIn.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
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
    
    fadeOut.fromValue = [NSNumber numberWithFloat:0.0f];
    fadeOut.toValue = [NSNumber numberWithFloat:0.4f];
    fadeIn.fromValue = [NSNumber numberWithFloat:0.4f];
    fadeIn.toValue = [NSNumber numberWithFloat:0.0f];
    
    group.animations = [NSArray arrayWithObjects: rotation, translation, translationZ, nil];
    group.fillMode = kCAFillModeForwards; 
    group.removedOnCompletion = NO;
    
    [CATransaction begin];
    [transformLayer addAnimation:group forKey:kFlipAnimationKey];
    [fadeOutMaskLayer addAnimation:fadeOut forKey:kFadeOutAnimationKey];
    [fadeInMaskLayer addAnimation:fadeIn forKey:kFadeInAnimationKey];
    [CATransaction commit];
}

-(void)setContentView:(UIView *)aContentView
{
    [contentView autorelease];
    [contentView removeFromSuperview];
    
    contentView = [aContentView retain];
    [self addSubview:contentView];
}

-(void)rotateToView:(UIView *)aView direction:(RSCubeViewRotationDirection)aDirection duration:(NSTimeInterval)aDuration
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
    self.fadeOutLayer = [self layerFromView:contentView withTransform:t];
    [transformLayer addSublayer:self.fadeOutLayer];
    
    //Init Fade out mask layer, used for fade options
    UIView* v = [[UIView alloc] initWithFrame:contentView.frame];
    if (aDirection == RSCubeViewRotationDirectionDown) {
        v.backgroundColor = [UIColor blackColor];
    } else if (aDirection == RSCubeViewRotationDirectionUp) {
        v.backgroundColor = [UIColor whiteColor];
    } else {
        v.backgroundColor = [UIColor darkGrayColor];
    }
    self.fadeOutMaskLayer = [self layerFromView:v withTransform:t];
    [transformLayer addSublayer:fadeOutMaskLayer];
    
    //Hide the actual content view during animation
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
    
    self.fadeInLayer = [self layerFromView:aView withTransform:t];
    //self.fadeInLayer.opacity = kOpacityFaded;
    [transformLayer addSublayer:self.fadeInLayer];
    
    //Init the Fade In Layer Mask
    if (aDirection == RSCubeViewRotationDirectionDown) {
        v.backgroundColor = [UIColor whiteColor];
    } else if (aDirection == RSCubeViewRotationDirectionUp) {
        v.backgroundColor = [UIColor blackColor];
    } else {
        v.backgroundColor = [UIColor darkGrayColor];
    }
    self.fadeInMaskLayer = [self layerFromView:v withTransform:t];
    [transformLayer addSublayer:fadeInMaskLayer];
    
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
    self.contentView = nextView;
    
    [transformLayer removeFromSuperlayer];
    self.fadeOutLayer = nil;
    self.fadeOutMaskLayer = nil;
    self.fadeInLayer = nil;
    self.fadeInMaskLayer = nil;
    self.transformLayer = nil;
    nextView = nil;
}

@end
