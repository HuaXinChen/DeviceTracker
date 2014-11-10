//
//  dbManager.m
//  DeviceTracker
//
//  Created by eddie on 2014-11-07.
//  Copyright (c) 2014 PNI. All rights reserved.
//

#import "dbManager.h"

//@interface dbManager()

//@end

@implementation dbManager

- (BOOL)initialize{
    //initialize db
    // Do any additional setup after loading the view, typically from a nib.
    
    NSString *docsDir;
    NSArray *dirPaths;
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    docsDir = dirPaths[0];
    
    // Build the path to the database file
    _databasePath = [[NSString alloc]
                     initWithString: [docsDir stringByAppendingPathComponent:
                                      @"deviceTracker.db"]];
    
    //Connect to database
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath: _databasePath ] == NO)
    {
        const char *dbpath = [_databasePath UTF8String];
        if (sqlite3_open(dbpath, &_deviceTrackerDB) == SQLITE_OK)
        {
            char *errMsg;
            //set schema if DEVICES table is not availabe
            const char *sql_stmt =
            "CREATE TABLE IF NOT EXISTS DEVICES (ID INTEGER PRIMARY KEY AUTOINCREMENT, DEVICEID TEXT, NAME TEXT, MADE TEXT)";
            
            //error message in case of database failure
            if (sqlite3_exec(_deviceTrackerDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                return false;
            }
            
            sqlite3_close(_deviceTrackerDB);
            return true;
        } else {
            return false;
        }
    }
    
    //if db exists, return true assuming table exists
    return true;
}

- (BOOL)checkOutDevice:(Device*) Device{
    return true;
}
- (BOOL)checkInWithDevice:(Device *) Device asUser:(User*)User{
    return true;
}

- (BOOL)testInsertData{
    
    sqlite3_stmt    *statement;
    const char *dbpath = [_databasePath UTF8String];
    if (sqlite3_open(dbpath, &_deviceTrackerDB) == SQLITE_OK)
    {
        
        //insert into tablename ( col1, col2, col3) values
        // (val1, val2, val3),
        // (val1, val2, val3),
        // (val1, val2, val3);
        NSString *combinedSQL = [NSString stringWithFormat:
                                 @"INSERT INTO DEVICES ( DEVICEID , NAME , MADE) VALUES "
                                 "(\"PNI-QA-MTD-001\", \"GALAXY S1\", \"Samsung1\" ),"
                                 "(\"PNI-QA-MTD-003\", \"GALAXY S3\", \"Samsung3\" ),"
                                 "(\"PNI-QA-MTD-005\", \"GALAXY S5\", \"Samsung5\" ),"
                                 "(\"PNI-QA-MTD-007\", \"GALAXY S7\", \"Samsung7\" )"
                                 ";"];
        
        const char *insert_stmt1 = [combinedSQL UTF8String];
        sqlite3_prepare_v2(_deviceTrackerDB, insert_stmt1, -1, &statement, NULL);
        return true;
    }
    else{
        return false;
    }
}

- (NSString*)testVerify: (NSMutableString*) deviceID{
    
    const char *dbpath = [_databasePath UTF8String];
    sqlite3_stmt *statement;
    
    //allocate memory for object
    NSString* nameAndMade = [[NSString alloc] init];
    
    if (sqlite3_open(dbpath, &_deviceTrackerDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"SELECT deviceid, name, made FROM devices WHERE deviceid=\"%@\"",
                              deviceID];
        const char *query_stmt = [querySQL UTF8String];
        
        
        if (sqlite3_prepare_v2(_deviceTrackerDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSString *nameField = [[NSString alloc]
                                       initWithUTF8String:(const char *)
                                       sqlite3_column_text(statement, 1)];
                
                NSString *madeField = [[NSString alloc]
                                       initWithUTF8String:(const char *)
                                       sqlite3_column_text(statement, 2)];

                nameAndMade = [nameAndMade stringByAppendingString:nameField];
                nameAndMade = [nameAndMade stringByAppendingString:madeField];
               
                
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(_deviceTrackerDB);
    }
    return nameAndMade;
}
    
- (instancetype)init
{
    self = [super init];
    return self;
}



@end