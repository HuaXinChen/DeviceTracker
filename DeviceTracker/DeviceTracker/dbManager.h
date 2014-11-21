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

@interface dbManager : NSObject

- (BOOL)initialize;
- (NSArray*)getDeviceStatus: (NSString*) deviceID;
- (BOOL)isDeviceFoundInDB:(NSString*) deviceID;
- (BOOL)borrowDevice: (NSString*) deviceID asUserName: (NSString*)userName;
- (BOOL)returnDevice:(NSString*) deviceID;

- (BOOL)insertData;


//create db
@property (strong, nonatomic) NSString *databasePath;
@property (nonatomic) sqlite3 *deviceTrackerDB;

@end