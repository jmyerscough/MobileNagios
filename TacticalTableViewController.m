//
//  TacticalTableViewController.m
//  MobileNagios
//
//  Created by Jason Myerscough on 24/03/2012.
//  Copyright (c) 2012 Jason Myerscough. All rights reserved.
//

#import "TacticalTableViewController.h"
#import "NagiosWebServiceReader.h"
#import "NagiosHost.h"
#import "NagiosHostService.h"

@interface TacticalTableViewController ()

@property (nonatomic, strong) NSArray *hostCollection;

@end

#define TACTICAL_SECTION_COUNT          2
#define HOST_ROW_COUNT_IN_TACTICAL_VIEW 4
#define NETWORK_HEALTH_SECTION          0
#define HOSTS_SECTION                   1 
#define SERVICES_SECTION                2 
#define HOST_OK_INDEX                   0
#define HOST_DOWN_INDEX                 1
#define HOST_PENDING_INDEX              2
#define HOST_UNREACHABLE_INDEX          3

#define HEALTH_STATUS_HEADER            @"Network Health"
#define HOST_SUMMARY_HEADER             @"Hosts"
#define SERVICES_SUMMARY_HEADER         @"Services"


@implementation TacticalTableViewController

@synthesize hostCollection = _hostCollection;

-(void) setHostCollection:(NSArray *)hostCollection
{
    if (_hostCollection != hostCollection)
    {
        _hostCollection = hostCollection;
        [self.tableView reloadData];    // reload the view everytime the data module is changed.
    }
}

#pragma mark Actions

- (IBAction)refreshData:(UIBarButtonItem *)sender
{
    NSLog(@"reload nagios data");
    
    // retrieve the data from the web server.
    NagiosWebServiceReader *nagiosService = [[NagiosWebServiceReader alloc] initWithURL:
                                             [[NSURL alloc] initWithString:@"http://192.168.44.130/status/"]];
    self.hostCollection =  [nagiosService retrieveNagiosStatusAndBlock];
    //nagiosService = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return TACTICAL_SECTION_COUNT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //int serviceCount = 0;
    //NagiosHost *currentHost = nil;
    
    switch (section)
    {
        case NETWORK_HEALTH_SECTION: return 2;
        case HOSTS_SECTION: return HOST_ROW_COUNT_IN_TACTICAL_VIEW;
        //case SERVICES_SECTION:
        //    for (int idx=0; idx < [self.hostCollection count]; idx++)
        //    {
        //        currentHost = [self.hostCollection objectAtIndex:idx];
        //        if (currentHost)
        //        {
        //            if (currentHost.services)
        //                serviceCount += [currentHost.services count];
        //        }
        //    }
        //    return serviceCount;
    }

    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Tactical Table Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    switch (indexPath.section)
    {
        case NETWORK_HEALTH_SECTION:
        {
            if (!indexPath.row)
            {
                int upHostCount = 0;
                float status = 0;
                
                for (int idx=0; idx < [self.hostCollection count]; idx++)
                {
                    NagiosHost *host = [self.hostCollection objectAtIndex:idx];
                    if (host.currentState == 1)
                        ++upHostCount;
                }
                
                if (self.hostCollection)
                {
                    int c = [self.hostCollection count];
                    status = (c / upHostCount) * 100;
                }
                else {
                    status = 0;
                }
                cell.textLabel.text = @"Hosts";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f%\%", status];
                return cell;
            }
            else
            {
                cell.textLabel.text = @"Services";
                cell.detailTextLabel.text = @"100%";    // TODO implement service information
            }
            break;
        }
        case HOSTS_SECTION:
        {
            int okCount = 0, downCount = 0, pendingCount = 0, unreachableCount = 0;
            
            for (int idx = 0; idx < [self.hostCollection count]; idx++)
            {
                NagiosHost *host = [self.hostCollection objectAtIndex:idx];
                
                if (host.currentState == 1) ++okCount;
            }
            
            switch (indexPath.row)
            {
                case HOST_OK_INDEX:
                    cell.textLabel.text = @"UP";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", okCount];
                    break;
                case HOST_DOWN_INDEX:
                    cell.textLabel.text = @"Down";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", downCount];
                    break;
                case HOST_PENDING_INDEX:
                    cell.textLabel.text = @"Pending";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", pendingCount];
                    break;
                case HOST_UNREACHABLE_INDEX:
                    cell.textLabel.text = @"Unreachable";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", unreachableCount];
                    break;                    
                default:
                    break;
            }
            
            
            return cell;
        }
        //case SERVICES_SECTION:
        //    break;            
        //default:
        //    break;
    }
    
    
    return cell;
}

// Sets the sections header
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case NETWORK_HEALTH_SECTION:
            return HEALTH_STATUS_HEADER;
        case HOSTS_SECTION:
            return HOST_SUMMARY_HEADER;
        default:
            return nil;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
