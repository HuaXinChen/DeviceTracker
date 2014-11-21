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

- (instancetype)init
{
    self = [super init];
    return self;
}

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
            "CREATE TABLE IF NOT EXISTS DEVICES (ID INTEGER PRIMARY KEY AUTOINCREMENT, DEVICEID TEXT, MODEL TEXT, MADE TEXT, OS TEXT, SCREENSIZE TEXT, USER TEXT, CHECKOUTTIME DATETIME)";
            
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

- (BOOL)isDeviceFoundInDB:(NSString*) deviceID{
    
    NSArray* status = [self getDeviceStatus:deviceID];
    
    return (!(status == nil || [status count] == 0 ));
    
}

- (NSArray*)getDeviceStatus: (NSString*) deviceID
{
    const char *dbpath = [_databasePath UTF8String];
    sqlite3_stmt *statement;
    
    //allocate memory for object
    NSArray* deviceStatus;
    
    if (sqlite3_open(dbpath, &_deviceTrackerDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"SELECT model, made, os, screensize, user, checkouttime FROM devices WHERE deviceid=\"%@\"",
                              deviceID];
        const char *query_stmt = [querySQL UTF8String];
        
        
        if (sqlite3_prepare_v2(_deviceTrackerDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSString *modelField = [[NSString alloc]
                                        initWithUTF8String:(const char *)
                                        sqlite3_column_text(statement, 0)];
                NSString *madeField = [[NSString alloc]
                                       initWithUTF8String:(const char *)
                                       sqlite3_column_text(statement, 1)];
                NSString *osField = [[NSString alloc]
                                     initWithUTF8String:(const char *)
                                     sqlite3_column_text(statement, 2)];
                NSString *screenField = [[NSString alloc]
                                         initWithUTF8String:(const char *)
                                         sqlite3_column_text(statement, 3)];
                NSString *userNameField = [[NSString alloc]
                                           initWithUTF8String:(const char *)
                                           sqlite3_column_text(statement, 4)];
                NSString *timeField = [[NSString alloc]
                                       initWithUTF8String:(const char *)
                                       sqlite3_column_text(statement, 5)];
                
                deviceStatus = [NSArray arrayWithObjects:modelField, madeField, osField, screenField, userNameField, timeField, nil];
                
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(_deviceTrackerDB);
    }
    return deviceStatus;
}

- (BOOL)borrowDevice: (NSString*) deviceID asUserName: (NSString*)userName
{
    NSString *querySQL = [NSString stringWithFormat:
                          @"UPDATE devices SET user = \"%@\" WHERE deviceid=\"%@\"",
                          userName,
                          deviceID];

    return [self executeSQLUsing: querySQL];
}

- (BOOL)returnDevice:(NSString*) deviceID
{
    NSString *querySQL = [NSString stringWithFormat:
                          @"UPDATE devices SET user = \"\" WHERE deviceid=\"%@\"",
                          deviceID];
    
    return [self executeSQLUsing: querySQL];}

- (BOOL)insertData{
    
    sqlite3_stmt    *statement;
    const char *dbpath = [_databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &_deviceTrackerDB) == SQLITE_OK)
    {
        NSString *combinedSQL = [NSString stringWithFormat:
                                 @"INSERT INTO DEVICES ( deviceid , model, made, os, screensize, user, checkouttime) VALUES "
                                 "(\"PNI-QA-MTD-006\", \"iPhone 5 (Black)\",       \"Apple\", \"8.0\",   \"4 inch\",   \"Eddie\",  \"now\"),"
                                 "(\"PNI-QA-MTD-001\", \"iPhone 5 (Black)\",       \"Apple\", \"7.1\",   \"4 inch\",   \"\",       \"\"   ),"
                                 "(\"PNI-QA-MTD-027\", \"iPhone 5 S (Gold)\",      \"Apple\", \"8.0\" ,  \"4 inch\",   \"Victor\", \"now\"),"
                                 "(\"PNI-QA-MTD-035\", \"iPhone 5 C (Green)\",     \"Apple\", \"7.1.2\", \"4 inch\",   \"Arthur\", \"now\"),"
                                 "(\"PNI-QA-MTD-037\", \"iPhone 6 (Space Gray)\",  \"Apple\", \"8.0.2\", \"4.7 inch\", \"\",       \"\"   ),"
                                 "(\"PNI-QA-MTD-003\", \"iPod Touch 4\",           \"Apple\", \"6.1.6\", \"3.5 inch\", \"Ted\",    \"now\"),"
                                 "(\"PNI-QA-MTD-032\", \"iPad Mini (White)\",      \"Apple\", \"8.0\",   \"7.9 inch\", \"\",       \"\"   ),"
                                 "(\"PNI-QA-MTD-025\", \"iPad Mini (Black)\",      \"Apple\", \"7.1.2\", \"7.9 inch\", \"Eddie\",  \"now\")"
                                 ";"];
        
        const char *insert_stmt1 = [combinedSQL UTF8String];
        sqlite3_prepare_v2(_deviceTrackerDB, insert_stmt1, -1, &statement, NULL);
        
        if (!sqlite3_step(statement) == SQLITE_DONE)
            return false;
        sqlite3_finalize(statement);
        sqlite3_close(_deviceTrackerDB);
        
        return true;
    }
    
    return false;
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


- (BOOL)executeSQLUsing: (NSString*) sqlStatement
{
    sqlite3_stmt    *statement;
    const char *dbpath = [_databasePath UTF8String];
    if (sqlite3_open(dbpath, &_deviceTrackerDB) == SQLITE_OK)
    {
        const char *insert_stmt1 = [sqlStatement UTF8String];
        sqlite3_prepare_v2(_deviceTrackerDB, insert_stmt1, -1, &statement, NULL);
        
        
        if (!sqlite3_step(statement) == SQLITE_DONE)
            return false;
        
        sqlite3_finalize(statement);
        sqlite3_close(_deviceTrackerDB);
        
        return true;
    }
    
    return false;
}



@end