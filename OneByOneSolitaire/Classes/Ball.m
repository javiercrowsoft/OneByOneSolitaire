//
//  Ball.m
//  OneByOneSolitaire
//
//  Created by Javier Alvarez on 10/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Ball.h"

// Import QuartzCore for animations
#import <QuartzCore/QuartzCore.h>

@implementation Ball

@synthesize board;
@synthesize x;
@synthesize y;
@synthesize cordX;
@synthesize cordY;
@synthesize lastX;
@synthesize lastY;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
}

- (void)restoreToInitialPosition {
	
	// Bounces the placard back to the center	
	CALayer *welcomeLayer = self.layer;
	
	// Create a keyframe animation to follow a path back to the center
	CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
	bounceAnimation.removedOnCompletion = NO;
	
	CGFloat animationDuration = 1.5;
	
	
	// Create the path for the bounces
	CGMutablePathRef thePath = CGPathCreateMutable();
	[board setBallOriginalPosition:self];
	m_location = CGPointMake(cordX+27, cordY+27);
	
	CGFloat midX = m_location.x;
	CGFloat midY = m_location.y;
	CGFloat originalOffsetX = self.center.x - midX;
	CGFloat originalOffsetY = self.center.y - midY;
	CGFloat offsetDivider = 4.0;
	
	BOOL stopBouncing = NO;
	
	// Start the path at the placard's current location
	CGPathMoveToPoint(thePath, NULL, self.center.x, self.center.y);
	CGPathAddLineToPoint(thePath, NULL, midX, midY);
	
	// Add to the bounce path in decreasing excursions from the center
	while (stopBouncing != YES) {
		CGPathAddLineToPoint(thePath, NULL, midX + originalOffsetX/offsetDivider, midY + originalOffsetY/offsetDivider);
		CGPathAddLineToPoint(thePath, NULL, midX, midY);
		
		offsetDivider += 4;
		animationDuration += 1/offsetDivider;
		if ((abs(originalOffsetX/offsetDivider) < 6) && (abs(originalOffsetY/offsetDivider) < 6)) {
			stopBouncing = YES;
		}
	}
	
	bounceAnimation.path = thePath;
	bounceAnimation.duration = animationDuration;
	CGPathRelease(thePath);
	
	// Create a basic animation to restore the size of the placard
	CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
	transformAnimation.removedOnCompletion = YES;
	transformAnimation.duration = animationDuration;
	transformAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
	
	
	// Create an animation group to combine the keyframe and basic animations
	CAAnimationGroup *theGroup = [CAAnimationGroup animation];
	
	// Set self as the delegate to allow for a callback to reenable user interaction
	theGroup.delegate = self;
	theGroup.duration = animationDuration;
	theGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
	
	theGroup.animations = [NSArray arrayWithObjects:bounceAnimation, transformAnimation, nil];
	
	
	// Add the animation group to the layer
	[welcomeLayer addAnimation:theGroup forKey:@"animatePlacardViewToCenter"];
	
	// Set the placard view's center and transformation to the original values in preparation for the end of the animation
	self.center = m_location;
	self.transform = CGAffineTransformIdentity;
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
	//Animation delegate method called when the animation's finished:
	// restore the transform and reenable user interaction
	self.transform = CGAffineTransformIdentity;
	self.userInteractionEnabled = YES;
}

//------------------------
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	m_location = self.center;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	
	if (!m_bFirstCallToMoved) {
		m_bFirstCallToMoved = YES;
		m_location = self.center;
		[self.superview bringSubviewToFront:self];
	}
	
	// If the touch was in the placardView, move the placardView to its location
	if ([touch view] == self) {
		CGPoint location = [touch locationInView:[self superview]];
		self.center = location;		
		return;
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
	m_bFirstCallToMoved = NO;
	
	// To manage double tap bug
	if (m_location.x == 0 && m_location.y == 0) { return; }
	
	UITouch *touch = [touches anyObject];
	NSUInteger tapCount = [touch tapCount];
	
	if (tapCount == 2) { 
		return;
	}
	
	if (self.center.x != m_location.x || self.center.y != m_location.y) {
	
		if (![board move:self :[touch locationInView:[board view]]]) {
			[self restoreToInitialPosition];
		}
	}
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	// To manage double tap bug
	if (m_location.x == 0 && m_location.y == 0) { return; }
	
	self.center = m_location;
	self.transform = CGAffineTransformIdentity;
}

//------------------------

- (void)dealloc {
    [super dealloc];
}


@end
