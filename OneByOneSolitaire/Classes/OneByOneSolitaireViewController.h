//
//  OneByOneSolitaireViewController.h
//  OneByOneSolitaire
//
//  Created by Javier Alvarez on 10/26/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsViewController.h"
#import "Ball.h"
#import "DataBase.h"

@interface OneByOneSolitaireViewController : UIViewController <SettingsViewControllerDelegate> {
	int ballImage;
	Ball *m_ballImages[32];
	CGRect m_boxes[33];
	int m_board[7][7];
	BOOL movingMode;
	DataBase *m_db;
	BOOL m_firstMove;
	int m_pl_id;
	NSString *m_pl_name;
	int m_gm_id;
	IBOutlet UILabel *lbPlayer;
	
	// moves
	int m_first_move_id;
	int m_last_move_id;
	int m_last_move_x1;
	int m_last_move_y1;
	int m_last_move_x2;
	int m_last_move_y2;
	UIBarButtonItem *cmdUndo;
	UIBarButtonItem *cmdRedo;
	
	SettingsViewController *m_controller;
}

@property (assign) int ballImage;
@property (assign) BOOL movingMode;

- (void) deal;
- (void) undo;
- (BOOL) redo;
- (void) showSettings;
- (BOOL) move:(Ball *) ball:(CGPoint) point;
- (void) showAlert: (NSString *)msg;
- (void) saveNewGame;
- (void) getPlayer;
- (void) saveMoveX1:(int) x1 Y1: (int) y1 X2: (int) x2 Y2: (int) y2;
- (void) getLastMove;
- (int) getPreviousMoveId:(int) moveId;
- (int) getNextMoveId:(int) moveId;
- (int) getLastGameNumber;
- (int) getActiveGameId;
- (void) activateGame;
- (void) activatePlayer;
- (void) setBallOriginalPosition:(Ball *) ball;
- (void) fadeBall:(Ball *) ball;
- (void) showBall:(Ball *) ball;
- (UIImage *) getImage;
- (void) reloadGame;
- (void) loadLastGame;
- (void) getBallImageFromDb;
- (void) saveBallImageInDb;
- (void) setBallOriginalPosition:(Ball *) ball;
- (void)createEditableCopyOfDatabaseIfNeeded;
@end

