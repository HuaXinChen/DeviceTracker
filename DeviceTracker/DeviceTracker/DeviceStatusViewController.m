//
//  DeviceStatusViewController.m
//  DeviceTracker
//
//  Created by QA-MAC on 2015-05-25.
//  Copyright (c) 2015 PNI. All rights reserved.
//

#import "DeviceStatusViewController.h"

@implementation DeviceStatusViewController


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
//    PFFile *thumbnail = [object objectForKey:@"imageFile"];
//    PFImageView *thumbnailImageView = (PFImageView*)[cell viewWithTag:100];
//    thumbnailImageView.image = [UIImage imageNamed:@"placeholder.jpg"];
//    thumbnailImageView.file = thumbnail;
//    [thumbnailImageView loadInBackground];
    
    UILabel *deviceIdLabel = (UILabel*) [cell viewWithTag:101];
    deviceIdLabel.text = [object objectForKey:@"deviceid"];
    deviceIdLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    
    UILabel *modelLable = (UILabel*) [cell viewWithTag:102];
    modelLable.text = [object objectForKey:@"model"];
    modelLable.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    
    UILabel *nameLable = (UILabel*) [cell viewWithTag:103];
    nameLable.text = [object objectForKey:@"user"];
    nameLable.font = [UIFont boldSystemFontOfSize:17.0];
    
    return cell;
}

- (void) objectsDidLoad:(NSError *)error
{
    [super objectsDidLoad:error];
    
    NSLog(@"error: %@", [error localizedDescription]);
}



@end
