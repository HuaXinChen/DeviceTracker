//
//  StatusViewController.m
//  DeviceTracker
//
//  Created by Victor Chen on 2014-11-21.
//  Copyright (c) 2014 PNI. All rights reserved.
//

#import "StatusViewController.h"
#import "StatusCell.h"
#import "Device.h"
#import "dbManager.h"

@implementation StatusViewController

NSArray *avaliableDevices;

NSArray *unAvaliableDevices;


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Initialize table data
    self.edgesForExtendedLayout=UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars=NO;
    self.automaticallyAdjustsScrollViewInsets=NO;
    self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
}

-(void)viewWillAppear:(BOOL)animated{
    
    dbManager *db = [[dbManager alloc] init];
    
    avaliableDevices = [db getAvailableDevices];
    
    unAvaliableDevices = [db getUnavailableDevices];
    
    [self.tableView reloadData];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2 ;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if(section == 0)
        return @"Available devices";
    if(section == 1)
        return @"Unavailble devices";
    return @"";
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UILabel *myLabel = [[UILabel alloc] init];
    myLabel.frame = CGRectMake(0, 0, 320, 22);
    myLabel.font = [UIFont boldSystemFontOfSize:22];
    myLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    
    UIView *headerView = [[UIView alloc] init];
    [headerView addSubview:myLabel];
    [headerView setBackgroundColor:[UIColor colorWithRed:52.0/220.0 green:170.0/220.0 blue:1.0 alpha:0.8]];
    
    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return [avaliableDevices count];
            break;
        case 1:
            return [unAvaliableDevices count];
            break;
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    StatusCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    switch (indexPath.section) {
        case 0:
            cell.deviceIDlbl.text = [[avaliableDevices objectAtIndex:indexPath.row] objectAtIndex:0];
            cell.modellbl.text = [[avaliableDevices objectAtIndex:indexPath.row] objectAtIndex:1];
            cell.userlbl.text = @"";
            [cell.statusImageView setImage:[UIImage imageNamed:@"available"]];
            break;
        case 1:
            cell.deviceIDlbl.text = [[unAvaliableDevices objectAtIndex:indexPath.row] objectAtIndex:0];
            cell.modellbl.text = [[unAvaliableDevices objectAtIndex:indexPath.row] objectAtIndex:1];
            cell.userlbl.text = [[unAvaliableDevices objectAtIndex:indexPath.row] objectAtIndex:2];
            [cell.statusImageView setImage:[UIImage imageNamed:@"unavailable"]];
            break;
        default:
            break;
    }
    
    return cell;
}

@end
