//
//  db.m
//  OneByOneSolitaire
//
//  Created by Javier Alvarez on 5/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "DataBase.h"


@implementation DataBase

-(NSString *)getLastErrorMsg {
	return m_lastErrorMsg;
}

-(BOOL)openDB: (NSString *) databaseName {
	int result = sqlite3_open([databaseName UTF8String], &m_database);
	if (result != SQLITE_OK)
	{
		sqlite3_close(m_database);
		m_lastErrorMsg = @"Failed to open database.";
		return NO;
	}
	else {
		return YES;
	}
}

-(BOOL)execute: (NSString *)sqlstmt {
	int result = sqlite3_exec(m_database, 
							  [sqlstmt UTF8String],
							  NULL, NULL, NULL);
	if (result != SQLITE_OK)
	{
		sqlite3_close(m_database);
		m_lastErrorMsg = @"Failed to execute sentence";
		return NO;
	}
	else {
		return YES;
	}
}

-(sqlite3_stmt *)openRS: (NSString *) sqlstmt {
	sqlite3_stmt *rs;
	sqlite3_prepare_v2(m_database, [sqlstmt UTF8String], -1, &rs, nil);
	return rs;
}

-(int)getLastPk {
	return sqlite3_last_insert_rowid(m_database);
}

@end
