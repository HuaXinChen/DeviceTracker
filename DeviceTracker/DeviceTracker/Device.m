//
//  Device.m
//  DeviceTracker
//
//  Created by Victor Chen on 2014-10-28.
//  Copyright (c) 2014 PNI. All rights reserved.
//

#import "Device.h"

@interface Device()


@end

@implementation Device



+ (BOOL)isDeviceAvailable:(NSArray*) deviceStatus{
    if ([(NSString*)deviceStatus[4] length] == 0)
        return true;
    
    return false;
}

+ (NSArray*)getCheckoutDevices
{
    //Get checkout devices from DB
    
    
    //NSArray* checkoutDevices = [[NSArray alloc] initWithObjects:<#(id), ...#>, nil]
    
    return [[NSArray alloc] init];
}

- (instancetype)init
{
    self = [super init];
    
    
    
    return self;
}

@end
