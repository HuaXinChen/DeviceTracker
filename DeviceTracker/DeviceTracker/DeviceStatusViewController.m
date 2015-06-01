//
//  DeviceStatusViewController.m
//  DeviceTracker
//
//  Created by QA-MAC on 2015-05-25.
//  Copyright (c) 2015 PNI. All rights reserved.
//

#import "DeviceStatusViewController.h"

@implementation DeviceStatusViewController

- (void) viewWillAppear:(BOOL)animated {
    
    [self loadObjects];
    
}

- (id)initWithCoder:(NSCoder *)aCoder
{
    self = [super initWithCoder:aCoder];
    if (self) {
        // The className to query on
        self.parseClassName = @"Devices";
        
        // The key of the PFObject to display in the label of the default cell style
        self.textKey = @"deviceid";
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = NO;
    }
    return self;
}

- (PFQuery *)queryForTable
{
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    
    [query orderByDescending:@"updatedAt"];
    
    return query;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    static NSString *simpleTableIdentifier = @"DeviceStatusCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    // Configure the cell
    
    UILabel *modelLable = (UILabel*) [cell viewWithTag:101];
    modelLable.text = [object objectForKey:@"model"];
    modelLable.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    
    UILabel *deviceIdLabel = (UILabel*) [cell viewWithTag:102];
    deviceIdLabel.text = [object objectForKey:@"deviceId"];
    deviceIdLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];

    UILabel *nameLable = (UILabel*) [cell viewWithTag:103];
    nameLable.text = [object objectForKey:@"user"];
    nameLable.font = [UIFont boldSystemFontOfSize:15.0];
    
    //Different background for odd and even rows
    if (indexPath.row % 2) {
        cell.backgroundColor = [UIColor whiteColor];
    }else {
        cell.backgroundColor = [UIColor colorWithWhite: 0.95 alpha:1];
    }
    
    //disable cell selection
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void) objectsDidLoad:(NSError *)error
{
    [super objectsDidLoad:error];
    
    NSLog(@"error: %@", [error localizedDescription]);
}



@end
