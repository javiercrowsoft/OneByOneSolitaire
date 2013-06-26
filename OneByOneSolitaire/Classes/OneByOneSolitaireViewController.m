//
//  OneByOneSolitaireViewController.m
//  OneByOneSolitaire
//
//  Created by Javier Alvarez on 10/26/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "OneByOneSolitaireViewController.h"


@implementation OneByOneSolitaireViewController

static const int posX[] = {  173, 126, 79,
/*                         */173, 126, 79,
/*               */267, 220, 173, 126, 79, 33, -14,
/*               */267, 220, 173, 126, 79, 33, -14,
/*               */267, 220, 173, 126, 79, 33, -14,
/*                         */173, 126, 79,
/*                         */173, 126, 79};

static const int posY[] = {  32, 32, 32,
/*                         */78, 78, 78,
/*               */124, 124, 124, 124, 124, 124, 124,
/*               */170, 170, 170, 170, 170, 170, 170,
/*               */216, 216, 216, 216, 216, 216, 216,
/*                         */262, 262, 262,
/*                         */308, 308, 308};

static const int cordX[] = { 4, 3, 2,
/*                         */4, 3, 2,
/*                   */6, 5, 4, 3, 2, 1, 0,
/*                   */6, 5, 4, 3, 2, 1, 0,
/*                   */6, 5, 4, 3, 2, 1, 0,
/*                         */4, 3, 2,
/*                         */4, 3, 2};

static const int cordY[] = { 0, 0, 0,
/*                         */1, 1, 1,
/*                   */2, 2, 2, 2, 2, 2, 2,
/*                   */3, 3, 3, 3, 3, 3, 3,
/*                   */4, 4, 4, 4, 4, 4, 4,
/*                         */5, 5, 5,
/*                         */6, 6, 6};

@synthesize ballImage;
@synthesize movingMode;

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	UIToolbar *toolbar;
	toolbar = [[self.view subviews] objectAtIndex:1]; 
	
	//Add buttons
	UIBarButtonItem *cmdDeal = [[UIBarButtonItem alloc] initWithTitle:@"deal" 
																	style:UIBarButtonItemStyleBordered 
																   target:self
																   action:@selector(deal)];
	
	cmdUndo = [[UIBarButtonItem alloc]
			   initWithBarButtonSystemItem:UIBarButtonSystemItemUndo
			   target:self
			   action:@selector(undo)];
	
	cmdRedo = [[UIBarButtonItem alloc]
			   initWithBarButtonSystemItem:UIBarButtonSystemItemRedo
			   target:self 
			   action:@selector(redo)];
	
	// i button
	UIView *view;
	view = [[UIView alloc] initWithFrame:CGRectMake(0,0,45,45)];
	UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
	infoButton.frame = CGRectMake(0, 0, 44, 44);
	[infoButton addTarget:self action:@selector(showSettings) forControlEvents:UIControlEventTouchUpInside];
	[view addSubview:infoButton];
	
	UIBarButtonItem *cmdSettings = [[UIBarButtonItem alloc]
								initWithCustomView:view];
	[view release];
	
	//Use this to put space in between your toolbox buttons
	UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																			  target:nil
																			  action:nil];
	
	//Add buttons to the array
	NSArray *items = [NSArray arrayWithObjects: cmdDeal, flexItem, cmdUndo, cmdRedo, flexItem, cmdSettings, nil];
	
	//release buttons
	[cmdDeal release];
	[flexItem release];
	
	//add array of buttons to toolbar
	[toolbar setItems:items animated:NO];

	for (int i = 0; i < 33; i++) {
		m_boxes[i].size.height = 47;
		m_boxes[i].size.width = 47;
		m_boxes[i].origin.x = posX[i];
		m_boxes[i].origin.y = posY[i];
	}
	
	// init database
	m_db = [[DataBase alloc] init];
	
	[self createEditableCopyOfDatabaseIfNeeded];
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
	
	if (![m_db openDB:[documentsDirectory stringByAppendingPathComponent:@"by1by1solitaire.db"]]) {
		[self showAlert:[m_db getLastErrorMsg]];
	}
	
	[self getPlayer];
	lbPlayer.text = m_pl_name;
	
	[self getBallImageFromDb];
	
	[self deal];
	[self loadLastGame];
}

- (void) loadLastGame {
	m_gm_id = [self getActiveGameId];
	if (m_gm_id != 0) {
		m_firstMove = NO;
		[self reloadGame];
	}
}

- (void) saveMoveX1:(int) x1 Y1: (int) y1 X2: (int) x2 Y2: (int) y2 {
	// because the player can undo moves, we need to delete every move
	// after the current move to start a new set of moves
	//
	if (![m_db execute:[NSString stringWithFormat:@"DELETE FROM Move WHERE mv_id > %d and gm_id = %d", m_last_move_id, m_gm_id]]) {
		[self showAlert:[m_db getLastErrorMsg]];
	}		
	
	if (![m_db execute:[NSString stringWithFormat:@"INSERT INTO Move (mv_x1, mv_y1, mv_x2, mv_y2, gm_id) values(%d, %d, %d, %d, %d)", 
						x1, y1, x2, y2, m_gm_id]]) {
		[self showAlert:[m_db getLastErrorMsg]];
	}
	else {
		m_last_move_id = [m_db getLastPk];
		if (m_first_move_id == 0)
			m_first_move_id = m_last_move_id;
	}
}

- (void) showAlert: (NSString *)msg {
	UIAlertView *view;
	view = [[UIAlertView alloc]
			initWithTitle: @"Database Error"
			message: msg
			delegate: self
			cancelButtonTitle: @"Close" otherButtonTitles: nil];
	[view show];
	[view autorelease];			
}
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	[cmdUndo release];
	[cmdRedo release];	
}

- (UIImage *) getImage {
	NSString *ballImageName;
	switch (ballImage) {
		case 0:
			ballImageName = @"bolita-blanca-celeste-amarilla-sombra.png";
			break;
		case 1:
			ballImageName = @"bolita-madera-clara-sombra.png";
			break;
		case 2:
			ballImageName = @"bolita-sombra.png";
			break;
		case 3:
			ballImageName = @"bolita-vidrio-sombra.png";
			break;
		case 4:
			ballImageName = @"bolita-lechera-sombra.png";
			break;
		case 5:
			ballImageName = @"bolita-blanco-negro-sombra.png";
			break;
		case 6:
			ballImageName = @"bolita-madera-oscura-sombra.png";
			break;
		case 7:
			ballImageName = @"bolita-azul-vidrio-sombra.png";
			break;
		default:
			break;
	}
	
	return [UIImage imageNamed:ballImageName];
	
}

- (void) deal {
	
	// moves
	m_firstMove = YES;
	m_first_move_id = 0;
	m_last_move_id = 0;

	cmdUndo.enabled = NO;
	cmdRedo.enabled = NO;
	
	// bals
	UIImage *image = [self getImage];

	for (int i = 0; i < 16; i++) {
		
		Ball *ball;
		if (m_ballImages[i] == nil) {
			ball = [[Ball alloc] initWithImage:image];
			ball.userInteractionEnabled = TRUE;
			ball.board = self;
			ball.x = cordX[i];
			ball.y = cordY[i];
			ball.lastX = 0;
			ball.lastY = 0;
			m_board[ball.x][ball.y] = 1;
			m_ballImages[i] = ball;
			ball.frame = CGRectMake(posX[i], posY[i], 55, 54);
			[self.view addSubview:ball];
			[ball release];
		}
		else {
			ball = m_ballImages[i];
			ball.x = cordX[i];
			ball.y = cordY[i];
			m_board[ball.x][ball.y] = 1;
			ball.frame = CGRectMake(posX[i], posY[i], 55, 54);
			[self showBall:ball];
			[ball setImage:image];
		}		
	}	
	for (int i = 17; i < 33; i++) {
		
		Ball *ball;
		if (m_ballImages[i-1] == nil) {
			ball = [[Ball alloc] initWithImage:image];
			ball.userInteractionEnabled = TRUE;
			ball.board = self;
			ball.lastX = 0;
			ball.lastY = 0;
			ball.x = cordX[i];
			ball.y = cordY[i];
			m_board[ball.x][ball.y] = 1;
			ball.frame = CGRectMake(posX[i], posY[i], 55, 54);
			[self.view addSubview:ball];
			m_ballImages[i-1] = ball;
			[ball release];
		}
		else {
			ball = m_ballImages[i-1];
			ball.x = cordX[i];
			ball.y = cordY[i];
			m_board[ball.x][ball.y] = 1;
			ball.frame = CGRectMake(posX[i], posY[i], 55, 54);
			[self showBall:ball];
			[ball setImage:image];
		}		
	}	
	m_board[3][3] = 0;
}

- (void) refreshImages{
	// bals
	
	UIImage *image = [self getImage];
	
	for (int i = 0; i < 16; i++) {
		
		Ball *ball;
		if (m_ballImages[i] != nil) {
			ball = m_ballImages[i];
			[ball setImage:image];
		}		
	}	
	for (int i = 17; i < 33; i++) {
		
		Ball *ball;
		if (m_ballImages[i-1] != nil) {
			ball = m_ballImages[i-1];
			[ball setImage:image];
		}		
	}	
}

- (void) setBallOriginalPosition:(Ball *) ball {
	int x = -1, y = -1;
	
	for (int i = 0; i < 33; i++) {
		if (cordX[i] == ball.x) {
			x = i;
			break;
		}						
	}
	for (int i = 0; i < 33; i++) {
		if (cordY[i] == ball.y) {
			y = i;
			break;
		}						
	}
	
	if (x >= 0 && y >= 0) {
		ball.cordX = posX[x]; 
		ball.cordY = posY[y];
	}
}

- (void) undo{
	[self getLastMove];
	if (m_last_move_id != 0) {

		int x, y;
		if (m_last_move_x1 != m_last_move_x2) {
			if (m_last_move_x1 > m_last_move_x2)
				x = m_last_move_x1 - 1;
			else
				x = m_last_move_x2 - 1;
		}
		else 
			x = m_last_move_x2;

		if (m_last_move_y1 != m_last_move_y2) {		
			if (m_last_move_y1 > m_last_move_y2)
				y = m_last_move_y1 - 1;
			else
				y = m_last_move_y2 - 1;
		}
		else 
			y = m_last_move_y2;
		
		for (int k = 0; k < 32; k++) {
			if (m_ballImages[k].lastX == x && m_ballImages[k].lastY == y) {
				[self showBall:m_ballImages[k]];
				m_ballImages[k].x = x;
				m_ballImages[k].y = y;
				m_ballImages[k].lastX = 0;
				m_ballImages[k].lastY = 0;
				m_board[x][y] = 1;
				break;
			}
		}
		m_board[m_last_move_x2][m_last_move_y2] = 0;
		m_board[m_last_move_x1][m_last_move_y1] = 1;

		for (int k = 0; k < 32; k++) {
			if (m_ballImages[k].x == m_last_move_x2 && m_ballImages[k].y == m_last_move_y2) {
				m_ballImages[k].x = m_last_move_x1;
				m_ballImages[k].y = m_last_move_y1;
				[m_ballImages[k] restoreToInitialPosition];
				break;
			}
		}
		
		cmdRedo.enabled = YES;
		
		// we move back
		//
		m_last_move_id = [self getPreviousMoveId:m_last_move_id];
		// if we have undo the first move
		//
		if (m_last_move_id < m_first_move_id) {
			m_first_move_id = 0;
			m_last_move_id = 0;
			cmdUndo.enabled = NO; 
		}
	}
	else {
		cmdUndo.enabled = NO;
	}
}

- (BOOL) redo{
	// we move forward
	//
	int mv_id = [self getNextMoveId:m_last_move_id];
	// if we have redo the last move
	//
	if (mv_id == 0) {
		cmdRedo.enabled = NO;
		return NO;
	}
	else {
		
		m_last_move_id = mv_id;
		[self getLastMove];
		
		if (m_last_move_id != 0) {
			
			int x, y;
			if (m_last_move_x1 != m_last_move_x2) {
				if (m_last_move_x1 > m_last_move_x2)
					x = m_last_move_x1 - 1;
				else
					x = m_last_move_x2 - 1;
			}
			else 
				x = m_last_move_x2;
			
			if (m_last_move_y1 != m_last_move_y2) {		
				if (m_last_move_y1 > m_last_move_y2)
					y = m_last_move_y1 - 1;
				else
					y = m_last_move_y2 - 1;
			}
			else 
				y = m_last_move_y2;
			
			for (int k = 0; k < 32; k++) {
				if (m_ballImages[k].x == x && m_ballImages[k].y == y) {
					[self fadeBall:m_ballImages[k]];
					m_ballImages[k].x = 0;
					m_ballImages[k].y = 0;
					m_ballImages[k].lastX = x;
					m_ballImages[k].lastY = y;
					m_board[x][y] = 0;
					break;
				}
			}
			m_board[m_last_move_x2][m_last_move_y2] = 1;
			m_board[m_last_move_x1][m_last_move_y1] = 0;
			
			for (int k = 0; k < 32; k++) {
				if (m_ballImages[k].x == m_last_move_x1 && m_ballImages[k].y == m_last_move_y1) {
					m_ballImages[k].x = m_last_move_x2;
					m_ballImages[k].y = m_last_move_y2;
					[m_ballImages[k] restoreToInitialPosition];
					break;
				}
			}
			
			cmdUndo.enabled = YES;
			
			// when we redo the first move m_fist_move_id is zero
			// we need to reset its value
			//
			if (m_first_move_id == 0)
				m_first_move_id = m_last_move_id;
			
			// we must check if there are more moves we can redo
			//
			int mv_id = [self getNextMoveId:m_last_move_id];
			if (mv_id == 0) {
				cmdRedo.enabled = NO;
				return NO;
			}
			else {
				return YES;
			}
		}
		else {
			return NO;
		}
	}
}

- (int) getPreviousMoveId:(int) moveId {
	int mv_id;
	if (moveId != 0) {
		sqlite3_stmt *rs;
		rs = [m_db openRS:[NSString stringWithFormat:@"SELECT max(mv_id) FROM Move WHERE mv_id < %d and gm_id = %d", moveId, m_gm_id]];
		if (sqlite3_step(rs) == SQLITE_ROW) {
			mv_id = sqlite3_column_int(rs, 0);
		}
		else {
			mv_id = 0;
		}
		sqlite3_finalize(rs);
	}
	else {
		mv_id = 0;
	}
	return mv_id;
}

- (int) getNextMoveId:(int) moveId {
	int mv_id;
	sqlite3_stmt *rs;
	rs = [m_db openRS:[NSString stringWithFormat:@"SELECT min(mv_id) FROM Move WHERE mv_id > %d and gm_id = %d", moveId, m_gm_id]];
	if (sqlite3_step(rs) == SQLITE_ROW) {
		mv_id = sqlite3_column_int(rs, 0);
	}
	else {
		mv_id = 0;
	}
	sqlite3_finalize(rs);
	return mv_id;
}

- (void) getLastMove {
	if (m_last_move_id != 0) {
		sqlite3_stmt *rs;
		rs = [m_db openRS:[NSString stringWithFormat:@"SELECT mv_x1, mv_y1, mv_x2, mv_y2 FROM Move WHERE mv_id = %d", m_last_move_id]];
		if (sqlite3_step(rs) == SQLITE_ROW) {
			m_last_move_x1 = sqlite3_column_int(rs, 0);
			m_last_move_y1 = sqlite3_column_int(rs, 1);
			m_last_move_x2 = sqlite3_column_int(rs, 2);
			m_last_move_y2 = sqlite3_column_int(rs, 3);			
		}
		sqlite3_finalize(rs);
	}
}

- (void) showSettings{
	m_controller = [[SettingsViewController alloc] initWithNibName:@"Settings" bundle:nil];
	m_controller.delegate = self;
	
	[m_controller setDataBase:m_db];
	m_controller.pl_id = m_pl_id;
	m_controller.playerName = lbPlayer.text;
	
	m_controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:m_controller animated:YES];
}

- (void)settingsViewControllerDidFinish:(SettingsViewController *)controller {
    BOOL reloadGame = NO;
	if (m_controller.pl_id != 0) {
		m_pl_id = m_controller.pl_id;
		[self activatePlayer];
		[self getPlayer];
		lbPlayer.text = m_pl_name;
		if (m_controller.gm_id != 0) {
			m_first_move_id = 0;
			m_last_move_id = 0;
			m_last_move_x1 = 0;
			m_last_move_y1 = 0;
			m_last_move_x2 = 0;
			m_last_move_y2 = 0;
			m_firstMove = NO;
			m_gm_id = m_controller.gm_id;
			[self activateGame];
			reloadGame = YES;
		}
	}
	[self dismissModalViewControllerAnimated:YES];	
	[m_controller release];	

	[self saveBallImageInDb];
	[self refreshImages];
	if (reloadGame) {
		[self deal];
		[self reloadGame];
	}
}

- (void) reloadGame {
	while ([self redo]) { }
}

- (BOOL) move:(Ball *) ball:(CGPoint) point {
	if (m_firstMove) {
		m_firstMove = NO;
		[self saveNewGame];
	}
	
	int originalX, originalY;
	originalX = ball.x;
	originalY = ball.y;
	
	for (int i = 0; i < 33; i++) {
		if(	  point.x >= m_boxes[i].origin.x
		   && point.y >= m_boxes[i].origin.y
		   && point.x <= m_boxes[i].origin.x + m_boxes[i].size.width
		   && point.y <= m_boxes[i].origin.y + m_boxes[i].size.height
		   ) {
			if (m_board[cordX[i]][cordY[i]] == 0) {
				int moveX, moveY;
				moveX = ball.x - cordX[i];
				moveY = ball.y - cordY[i];
				
				if ((abs(moveX) == 2 || moveX == 0) && (abs(moveY) == 2 || moveY == 0)) {
					if (!(abs(moveX) != 0 && abs(moveY) != 0) || movingMode) {
						int x, y;
						x = ball.x - (moveX / 2);
						y = ball.y - (moveY / 2);
						if (m_board[x][y] == 1) {
							m_board[x][y] = 0;
							for (int k = 0; k < 32; k++) {
								if (m_ballImages[k].x == x && m_ballImages[k].y == y) {
									[self fadeBall:m_ballImages[k]];
									m_ballImages[k].lastX = m_ballImages[k].x;
									m_ballImages[k].lastY = m_ballImages[k].y;
									m_ballImages[k].x = 0;
									m_ballImages[k].y = 0;
									break;
								}
							}
							m_board[cordX[i]][cordY[i]] = 1;
							m_board[ball.x][ball.y] = 0;
							ball.x = cordX[i];
							ball.y = cordY[i];
							ball.frame = CGRectMake(m_boxes[i].origin.x, m_boxes[i].origin.y, 55, 54);
							
							[self saveMoveX1:originalX Y1:originalY X2:ball.x Y2:ball.y];
							cmdUndo.enabled = YES;
							
							return YES;
						}
						else {
							return NO;
						}
					}
					else {
						return NO;
					}
				}
				else {
					return NO;
				}
			}
			else {
				return NO;
			}
		}
	}
	return NO;
}

- (void) getPlayer {
	sqlite3_stmt *rs;
	rs = [m_db openRS:@"SELECT pl_id, pl_name FROM Player WHERE pl_activo <> 0"];
	
	if (sqlite3_step(rs) == SQLITE_ROW)
	{
		m_pl_name = [[NSString alloc] initWithUTF8String:
					 (char *)sqlite3_column_text(rs, 1)];
		m_pl_id = sqlite3_column_int(rs, 0);
	}
	else {
		if (![m_db execute:[NSString stringWithFormat:@"INSERT INTO Player (pl_name, pl_activo) VALUES('%@', 1)",
							[[UIDevice currentDevice] name]]]) {
			[self showAlert:[m_db getLastErrorMsg]];
		}
		else {
			m_pl_id = [m_db getLastPk];
			m_pl_name = [[UIDevice currentDevice] name];
		}
	}
	sqlite3_finalize(rs);
}

- (void) saveNewGame {
	int gm_number = [self getLastGameNumber] + 1;
	NSString *gm_name = [NSString stringWithFormat:@"Game %05d", gm_number];
	if (![m_db execute:[NSString stringWithFormat:@"INSERT INTO Game (gm_name, gm_number, gm_activo, pl_id) VALUES('%@', %d, 0, %d)", gm_name, gm_number, m_pl_id]]) {
		[self showAlert:[m_db getLastErrorMsg]];
	}
	else {
		m_gm_id = [m_db getLastPk];
		[self activateGame];
	}
}

- (void) activateGame {
	if (![m_db execute:[NSString stringWithFormat:@"UPDATE Game SET gm_activo = 0 WHERE pl_id = %d", m_pl_id]]) {
		[self showAlert:[m_db getLastErrorMsg]];
	}
	if (![m_db execute:[NSString stringWithFormat:@"UPDATE Game SET gm_activo = 1 WHERE pl_id = %d and gm_id = %d", m_pl_id, m_gm_id]]) {
		[self showAlert:[m_db getLastErrorMsg]];
	}
}

- (void) activatePlayer {
	if (![m_db execute:[NSString stringWithFormat:@"UPDATE Player SET pl_activo = 0 WHERE pl_id <> %d", m_pl_id]]) {
		[self showAlert:[m_db getLastErrorMsg]];
	}
	if (![m_db execute:[NSString stringWithFormat:@"UPDATE Player SET pl_activo = 1 WHERE pl_id = %d", m_pl_id]]) {
		[self showAlert:[m_db getLastErrorMsg]];
	}
}

-(int) getLastGameNumber {
	sqlite3_stmt *rs;
	int gameNumber;
	rs = [m_db openRS:[NSString stringWithFormat:@"SELECT max(gm_number) FROM Game WHERE pl_id = %d", m_pl_id]];
	if (sqlite3_step(rs) == SQLITE_ROW)
	{
		gameNumber = sqlite3_column_int(rs, 0);
	}
	else {
		gameNumber = 0;
	}
	sqlite3_finalize(rs);	
	return gameNumber;
}

-(int) getActiveGameId {
	sqlite3_stmt *rs;
	int gmId;
	rs = [m_db openRS:[NSString stringWithFormat:@"SELECT gm_id FROM Game WHERE pl_id = %d and gm_activo <> 0", m_pl_id]];
	if (sqlite3_step(rs) == SQLITE_ROW)
	{
		gmId = sqlite3_column_int(rs, 0);
	}
	else {
		gmId = 0;
	}
	sqlite3_finalize(rs);	
	return gmId;
}

- (void) getBallImageFromDb {
	sqlite3_stmt *rs;
	rs = [m_db openRS:@"SELECT st_value FROM Settings WHERE st_code = 1"]; // 1 ballimage
	if (sqlite3_step(rs) == SQLITE_ROW)
	{
		ballImage = sqlite3_column_int(rs, 0);
	}
	else {
		ballImage = 0;
	}
	sqlite3_finalize(rs);		
}

- (void) saveBallImageInDb {
	BOOL update = NO;
	sqlite3_stmt *rs;
	rs = [m_db openRS:@"SELECT st_value FROM Settings WHERE st_code = 1"]; // 1 ballimage
	if (sqlite3_step(rs) == SQLITE_ROW)
	{
		update = YES;
	}
	else {
		update = NO;
	}
	sqlite3_finalize(rs);
	if (update) {
		if (![m_db execute:[NSString stringWithFormat:@"UPDATE Settings SET st_value = %d WHERE st_code = 1", ballImage]])
			[self showAlert:[m_db getLastErrorMsg]];	
	}
	else {
		if (![m_db execute:[NSString stringWithFormat:@"INSERT INTO Settings (st_code, st_value) VALUES(1,%d)", ballImage]])
			[self showAlert:[m_db getLastErrorMsg]];	
	}		
}

- (void)dealloc {
    [super dealloc];
}

- (void) fadeBall:(Ball *) ball {

	[UIView beginAnimations:@"animateTableView" context:nil];
	[UIView setAnimationDuration:0.9];
	[ball setAlpha:0.0]; //this will change the newView alpha from its previous zero value to 0.5f
	[UIView commitAnimations];

}

- (void) showBall:(Ball *) ball {

	[UIView beginAnimations:@"animateTableView" context:nil];
	[UIView setAnimationDuration:0.9];
	[ball setAlpha:1.0]; //this will change the newView alpha from its previous zero value to 0.5f
	[UIView commitAnimations];

}

// Creates a writable copy of the bundled default database in the application Documents directory.
- (void)createEditableCopyOfDatabaseIfNeeded {
    // First, test for existence.
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"by1by1solitaire.db"];
    success = [fileManager fileExistsAtPath:writableDBPath];
    if (success) return;
    // The writable database does not exist, so copy the default to the appropriate location.
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"by1by1solitaire.db"];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    if (!success) {
        NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    }
}

@end
