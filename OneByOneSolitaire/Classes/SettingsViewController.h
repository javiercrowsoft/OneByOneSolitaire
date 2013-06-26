//
//  SettingsViewControler.h
//  OneByOneSolitaire
//
//  Created by Javier Alvarez on 10/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataBase.h"

@protocol SettingsViewControllerDelegate;

@interface SettingsViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate> {
	id <SettingsViewControllerDelegate> delegate;
	IBOutlet UISwitch *chkMovingMode;
	IBOutlet UIScrollView *scrollView;
	IBOutlet UIPickerView * userPicker;
	IBOutlet UIPickerView * gamePicker;
	IBOutlet UIButton * newPlayer;
	IBOutlet UIButton * selectGame;
	IBOutlet UITextField * newPlayerName;
	IBOutlet UILabel * selectedGame;
	DataBase *m_db;
	NSMutableArray *m_users;
	NSMutableArray *m_userIds;
	NSMutableArray *m_games;
	NSMutableArray *m_gameIds;
	NSString *playerName;
	int pl_id;
	int gm_id;
	int m_selectedRowUser;
}

@property (nonatomic, assign) id <SettingsViewControllerDelegate> delegate;
@property (nonatomic, retain) UISwitch *chkMovingMode;
@property (assign) int pl_id;
@property (assign) int gm_id;
@property (nonatomic, copy) NSString *playerName;

- (IBAction)done;
- (IBAction)setBallImage0;
- (IBAction)setBallImage1;
- (IBAction)setBallImage2;
- (IBAction)setBallImage3;
- (IBAction)setBallImage4;
- (IBAction)setBallImage5;
- (IBAction)setBallImage6;
- (IBAction)setBallImage7;
- (IBAction)setMovingMode;

- (IBAction)newPlayerClick;

- (void) loadDataBaseData;
- (void) loadGames;
- (void) setDataBase: (DataBase *)db;
- (void) showAlert: (NSString *)msg;
@end

@protocol SettingsViewControllerDelegate
@property (assign) int ballImage;
@property (readwrite,assign) BOOL movingMode;
- (void)settingsViewControllerDidFinish:(SettingsViewController *)controller;
@end