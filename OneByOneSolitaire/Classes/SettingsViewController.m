//
//  SettingsViewControler.m
//  OneByOneSolitaire
//
//  Created by Javier Alvarez on 10/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"


@implementation SettingsViewController

@synthesize delegate;
@synthesize chkMovingMode;
@synthesize pl_id;
@synthesize playerName;
@synthesize gm_id;

- (IBAction)setBallImage0 {
	self.delegate.ballImage = 0;	
}
- (IBAction)setBallImage1 {
	self.delegate.ballImage = 1;	
}
- (IBAction)setBallImage2 {
	self.delegate.ballImage = 2;	
}
- (IBAction)setBallImage3 {
	self.delegate.ballImage = 3;	
}
- (IBAction)setBallImage4 {
	self.delegate.ballImage = 4;	
}
- (IBAction)setBallImage5 {
	self.delegate.ballImage = 5;	
}
- (IBAction)setBallImage6 {
	self.delegate.ballImage = 6;	
}
- (IBAction)setBallImage7 {
	self.delegate.ballImage = 7;	
}

- (IBAction)done {
	[self.delegate settingsViewControllerDidFinish:self];	
}

- (IBAction)setMovingMode {
	if (chkMovingMode.on) {
		self.delegate.movingMode = YES;
	}
	else {
		self.delegate.movingMode = NO;
	}
}

- (IBAction) newPlayerClick {
	if ([newPlayerName.text length] > 0) {
		// new user
		if (pl_id == 0) {
			if (![m_db execute:[NSString stringWithFormat:@"INSERT INTO Player (pl_name, pl_activo) VALUES('%@', 1)",
								newPlayerName.text]]) {
				[self showAlert:[m_db getLastErrorMsg]];
			}
			else {
				pl_id = [m_db getLastPk];
				playerName = newPlayerName.text;
				[m_userIds addObject:[NSNumber numberWithInt:pl_id]];
				[m_users addObject:newPlayerName.text];				
				[userPicker reloadAllComponents];
				[userPicker selectRow:[m_users count]-1 inComponent:0 animated:YES];
				[newPlayerName resignFirstResponder];
			}
		}
		else {
			if (![m_db execute:[NSString stringWithFormat:@"UPDATE Player SET pl_name = '%@' WHERE pl_id = %d",
								newPlayerName.text, pl_id]]) {
				[self showAlert:[m_db getLastErrorMsg]];
			}	
			else {
				playerName = newPlayerName.text;
				[userPicker reloadAllComponents];
				[userPicker selectRow:m_selectedRowUser inComponent:0 animated:YES];
				[newPlayerName resignFirstResponder];
			}
		}
	}
}


// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle {
	
	if (self = [super initWithNibName:nibName bundle:nibBundle]) {
		self.wantsFullScreenLayout = YES;
	}
	return self;
}

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[chkMovingMode setOn:self.delegate.movingMode];
	scrollView.contentSize = CGSizeMake(320, 1200);
	[self loadDataBaseData];
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

- (void) viewDidAppear:(BOOL)animated {
	newPlayerName.text = playerName;
	[userPicker selectRow:m_selectedRowUser inComponent:0 animated:YES];
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[m_users release];
	[m_games release];
	[m_userIds release];
	[m_gameIds release];
    [super dealloc];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView { 
	// This method needs to be used. It asks how many columns will be used in the UIPickerView
	return 1; // We only need one column so we will return 1.
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component { 
	// This method also needs to be used. This asks how many rows the UIPickerView will have.
	if (thePickerView == userPicker) {
		return [m_users count]; // We will need the amount of rows that we used in the pickerViewArray, so we will return the count of the array.
	}
	else {
		return [m_games count];
	}
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component { 
	// This method asks for what the title or label of each row will be.
	if (thePickerView == userPicker) {
		return [m_users objectAtIndex:row]; // We will set a new row for every string used in the array.
	}
	else {
		return [m_games objectAtIndex:row];
	}	
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component { 
	// And now the final part of the UIPickerView, what happens when a row is selected.
	[newPlayerName resignFirstResponder];
	if (thePickerView == userPicker) {
		if (row >= 0 && row < [m_users count]) {
			pl_id = [[m_userIds objectAtIndex:row] integerValue];
			playerName = [m_users objectAtIndex:row];		
			newPlayerName.text = playerName;
			[self loadGames];
			[gamePicker reloadAllComponents];
			m_selectedRowUser = row;
		}
		// new user
		if (row == 0) {
			[newPlayerName becomeFirstResponder];
			newPlayerName.text = @"";
		}
	}
	else {
		if (thePickerView == gamePicker) {
			if (row >= 0 && row < [m_games count]) {
				selectedGame.text = [m_games objectAtIndex:row];
				gm_id = [[m_gameIds objectAtIndex:row] integerValue];
			}
		}
	}
}

- (void) setDataBase: (DataBase *)db {
	m_db = db;
}

- (void) loadDataBaseData {
	sqlite3_stmt *rs;
	
	m_users = [[NSMutableArray alloc] init];
	m_userIds = [[NSMutableArray alloc] init];

	[m_users addObject:@"[new user]"];
	[m_userIds addObject:[NSNumber numberWithInteger:0]];
	
	rs = [m_db openRS:@"SELECT pl_name, pl_id FROM Player ORDER BY pl_name"];
	int row  = 1;
	int plId = 0;
	while (sqlite3_step(rs) == SQLITE_ROW)
	{
		[m_users addObject:[[NSString alloc] initWithUTF8String:
					 (char *)sqlite3_column_text(rs, 0)]];
		plId = sqlite3_column_int(rs, 1);
		[m_userIds addObject:[NSNumber numberWithInteger:plId]];
		if (pl_id == plId)
			m_selectedRowUser = row;
		row++;
	}
	sqlite3_finalize(rs);
	
	[self loadGames];

}

- (void) loadGames {
	sqlite3_stmt *rs;
	
	if (m_games != nil)
		[m_games release];
	if (m_gameIds != nil)
		[m_gameIds release];
	
	m_games = [[NSMutableArray alloc] init];
	m_gameIds = [[NSMutableArray alloc] init];

	[m_games addObject:@"[select an old game]"];
	[m_gameIds addObject:[NSNumber numberWithInteger:0]];
	
	rs = [m_db openRS:[NSString stringWithFormat:@"SELECT gm_name, gm_id FROM Game WHERE pl_id = %d ORDER BY gm_name", pl_id]];
	while (sqlite3_step(rs) == SQLITE_ROW)
	{
		[m_games addObject:[[NSString alloc] initWithUTF8String:
							(char *)sqlite3_column_text(rs, 0)]];
		[m_gameIds addObject:[NSNumber numberWithInteger:sqlite3_column_int(rs, 1)]];
	}
	sqlite3_finalize(rs);
	if (m_games.count > 0)
		selectedGame.text = [m_games objectAtIndex:(m_games.count-1)];	
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

@end
