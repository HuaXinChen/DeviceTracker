//
//  User.m
//  DeviceTracker
//
//  Created by Victor Chen on 2014-10-28.
//  Copyright (c) 2014 PNI. All rights reserved.
//

#import "User.h"

@interface User()

@property(strong, nonatomic) NSArray* deviceList;

@end

@implementation User

- (instancetype)init
{
    self = [super init];
    
    
    
    return self;
}


- (BOOL)checkout:(Device*)device
{
    return true;
}

- (BOOL)checkin:(Device*)device
{
    return true;
}

- (BOOL)extend:(Device*)device
{
    return true;
}


- (NSArray*)getCheckoutDevices
{
    return _deviceList;
}


@end
