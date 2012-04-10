//
//  ServiceDetailViewController.m
//  MobileNagios
//
//  Created by Jason Myerscough on 10/04/2012.
//  Copyright (c) 2012 Jason Myerscough. All rights reserved.
//

#import "ServiceDetailViewController.h"
#import "NagiosHostService.h"

@interface ServiceDetailViewController ()
@property (nonatomic, strong) NagiosHostService *service;
@end

#define STATUS_INFO_INDEX       0
#define PERFORMANCE_INFO_INDEX  1
#define LAST_CHECKED_INDEX      2
#define CHECK_LATENCY_INDEX     3

#define ROWS_IN_SECTION         4

#define STATUS_INFO_CAPTION     @"Status Information"
#define PERFORMANCE_INFO_CAPTION    @"Performance Data"
#define LAST_CHECKED_CAPTION    @"Last Checked"
#define CHECK_LATENCY_CAPTION   @"Check Latency"

@implementation ServiceDetailViewController

@synthesize service = _service;

- (void)setCurrentService:(NagiosHostService *)service
{
    self.service = service;
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"service Details";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    NSDate *lastCheckedDate = nil;
    
    // Configure the cell...
    switch (indexPath.row)
    {
        case STATUS_INFO_INDEX:
            cell.textLabel.text = STATUS_INFO_CAPTION;
            cell.detailTextLabel.text = self.service.pluginOutput;
            break;
        case PERFORMANCE_INFO_INDEX: 
            cell.textLabel.text = PERFORMANCE_INFO_CAPTION;
            cell.detailTextLabel.text = self.service.performanceData;
            break;
        case LAST_CHECKED_INDEX: 
            lastCheckedDate = [[NSDate alloc] initWithTimeIntervalSince1970:self.service.lastCheck];
            cell.textLabel.text = LAST_CHECKED_CAPTION;
            cell.detailTextLabel.text = [lastCheckedDate description];
            break;
        case CHECK_LATENCY_INDEX: 
            cell.textLabel.text = CHECK_LATENCY_CAPTION;
            cell.detailTextLabel.text = [[NSString alloc ] initWithFormat:@"%.2f seconds", self.service.checkLatency];
            break;
    }
    
    return cell;
}

@end
