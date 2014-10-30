//
//  ViewController.m
//  DeviceTracker
//
//  Created by Victor Chen on 2014-10-28.
//  Copyright (c) 2014 PNI. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *scannerView;

@property (weak, nonatomic) IBOutlet UILabel *displayLable;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)scanPressed:(UIButton *)sender {
    _displayLable.text = @"test scan pressed";
}

- (IBAction)statusPressed:(UIButton *)sender {
    _displayLable.text = @"test status pressed";
}


@end
