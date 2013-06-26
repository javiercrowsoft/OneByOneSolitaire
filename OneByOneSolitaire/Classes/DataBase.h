//
//  db.h
//  OneByOneSolitaire
//
//  Created by Javier Alvarez on 5/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface DataBase : NSObject {
	UIView *view;
	NSString *m_lastErrorMsg;
	sqlite3 *m_database;
}

-(BOOL)openDB: (NSString *) databaseName;
-(BOOL)execute: (NSString *) sqlstmt;
-(sqlite3_stmt *)openRS: (NSString *) sqlstmt;
-(NSString *)getLastErrorMsg;
-(int)getLastPk;
@end
