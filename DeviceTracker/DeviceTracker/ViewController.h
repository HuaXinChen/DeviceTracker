//
//  ViewController.h
//  DeviceTracker
//
//  Created by Victor Chen on 2014-10-28.
//  Copyright (c) 2014 PNI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import <AVFoundation/AVFoundation.h>
#import "dbManager.h"

@interface ViewController : UIViewController <AVCaptureMetadataOutputObjectsDelegate>

@property (weak, nonatomic) IBOutlet UIView *viewPreview;
@property (weak, nonatomic) IBOutlet UILabel *lblStatus;
@property (weak, nonatomic) IBOutlet UILabel *lblOutput;
@property (weak, nonatomic) IBOutlet UIButton *btnScan;

//verify button
- (IBAction)scanPressed:(id)sender;
- (IBAction)statusPressed:(id)sender;
- (IBAction)verifyPressed:(id)sender;
- (IBAction)insertPressed:(id)sender;




//create db
//@property (strong, nonatomic) NSString *databasePath;
//@property (nonatomic) sqlite3 *deviceTrackerDB;
@end

