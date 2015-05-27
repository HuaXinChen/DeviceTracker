//
//  ViewController.h
//  DeviceTracker
//
//  Created by Victor Chen on 2014-10-28.
//  Copyright (c) 2015 PNI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Parse/PFObject.h>
#import <Parse/PFQuery.h>

@interface ViewController : UIViewController <AVCaptureMetadataOutputObjectsDelegate,UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *viewPreview;
@property (weak, nonatomic) IBOutlet UILabel *lblStatus;

@end

