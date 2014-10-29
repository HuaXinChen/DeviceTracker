//
//  Device.h
//  DeviceTracker
//
//  Created by Victor Chen on 2014-10-28.
//  Copyright (c) 2014 PNI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Device : NSObject

@property (nonatomic) NSUInteger *deviceID;
@property (strong, nonatomic) NSString *deviceName;
@property (strong, nonatomic) NSString *serialNumber;
@property (strong, nonatomic) NSString *brand;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSString *model;
@property (strong, nonatomic) NSString *os;

+ (NSArray*)getCheckoutDevices;

@end