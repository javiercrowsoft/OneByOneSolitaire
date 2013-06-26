//
//  Ball.h
//  OneByOneSolitaire
//
//  Created by Javier Alvarez on 10/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Ball : UIImageView {
	int x, y;
	int cordX, cordY;
	int lastX, lastY;
	id board;
	BOOL m_bFirstCallToMoved;
	CGPoint m_location;
}

@property (assign) id board;
@property (assign) int x;
@property (assign) int y;
@property (assign) int cordX;
@property (assign) int cordY;
@property (assign) int lastX;
@property (assign) int lastY;

- (void)restoreToInitialPosition;

@end
