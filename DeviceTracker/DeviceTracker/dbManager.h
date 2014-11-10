//
//  dbManager.h
//  DeviceTracker
//
//  Created by eddie on 2014-11-07.
//  Copyright (c) 2014 PNI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "Device.h"
#import "User.h"

@interface dbManager : NSObject

- (BOOL)initialize;
- (BOOL)checkOutDevice: (Device*) Device;
- (BOOL)checkInWithDevice:(Device *) Device asUser:(User*)User;
- (BOOL)testInsertData;
- (NSMutableString*)testVerify: (NSMutableString*) deviceID;

//create db
@property (strong, nonatomic) NSString *databasePath;
@property (nonatomic) sqlite3 *deviceTrackerDB;

@end