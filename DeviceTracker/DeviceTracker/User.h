//
//  User.h
//  DeviceTracker
//
//  Created by Victor Chen on 2014-10-28.
//  Copyright (c) 2014 PNI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Device.h"


@interface User : NSObject

@property (nonatomic) NSUInteger *userID;
@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *title;


- (BOOL)checkout:(Device*)device;
- (BOOL)checkin:(Device*)device;
- (BOOL)extend:(Device*)device;

- (NSArray*)getCheckoutDevices;

@end
