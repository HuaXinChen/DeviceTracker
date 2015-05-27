//
//  StatusCell.h
//  DeviceTracker
//
//  Created by Victor Chen on 2014-12-02.
//  Copyright (c) 2015 PNI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StatusCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *deviceIDlbl;
@property (nonatomic, weak) IBOutlet UILabel *modellbl;
@property (nonatomic, weak) IBOutlet UILabel *userlbl;
@property (nonatomic, weak) IBOutlet UIImageView *statusImageView;

@end