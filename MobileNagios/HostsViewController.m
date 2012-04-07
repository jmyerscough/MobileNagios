//
//  HostsViewController.m
//  MobileNagios
//
//  Created by Jason Myerscough on 07/04/2012.
//  Copyright (c) 2012 Jason Myerscough. All rights reserved.
//

#import "HostsViewController.h"
#import "NagiosHost.h"

@interface HostsViewController ()
@property (nonatomic, strong) NSMutableArray *upHostsCollection;
@property (nonatomic, strong) NSMutableArray *downHostsCollection;
@property (nonatomic, strong) NSMutableArray *pendingHostsCollection;
@property (nonatomic, strong) NSMutableArray *unreachableHostsCollection;
@end

#define HOST_SECTION_COUNT          4

#define HOST_OK_SECTION             0       
#define HOST_DOWN_SECTION           1
#define HOST_PENDING_SECTION        2
#define HOST_UNREACHABLE_SECTION    3

#define HOST_OK_HEADER             @"Up"       
#define HOST_DOWN_HEADER           @"Down"
#define HOST_PENDING_HEADER        @"Pending"
#define HOST_UNREACHABLE_HEADER    @"Unreachable"

@implementation HostsViewController

@synthesize upHostsCollection = _upHostsCollection;
@synthesize downHostsCollection = _downHostsCollection;
@synthesize pendingHostsCollection = _pendingHostsCollection;
@synthesize unreachableHostsCollection = _unreachableHostsCollection;

- (void)setHostCollection:(NSArray *)hostCollection
{
    if (!self.upHostsCollection) self.upHostsCollection = [[NSMutableArray alloc] init];
    if (!self.downHostsCollection) self.downHostsCollection = [[NSMutableArray alloc] init];
    if (!self.pendingHostsCollection) self.pendingHostsCollection = [[NSMutableArray alloc] init];
    if (!self.unreachableHostsCollection) self.unreachableHostsCollection = [[NSMutableArray alloc] init];
    
    // remove all elements from the status arrays
    [self.upHostsCollection removeAllObjects];
    [self.downHostsCollection removeAllObjects];
    [self.pendingHostsCollection removeAllObjects];
    [self.unreachableHostsCollection removeAllObjects];    
    
    // add the hosts to the different status arrays
    for (int idx = 0; idx < [hostCollection count]; idx++)
    {
        NagiosHost *host = [hostCollection objectAtIndex:idx];
        
        switch (host.currentState)
        {
            case NagiosHostUp: [self.upHostsCollection addObject:host]; break;
            case NagiosHostDown: [self.downHostsCollection addObject:host]; break;
            case NagiosHostPending: [self.pendingHostsCollection addObject:host]; break;
            case NagiosHostUnreachable: [self.unreachableHostsCollection addObject:host]; break;
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return HOST_SECTION_COUNT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case HOST_OK_SECTION: return [self.upHostsCollection count];
        case HOST_DOWN_SECTION: return [self.downHostsCollection count];
        case HOST_PENDING_SECTION: return [self.pendingHostsCollection count];
        case HOST_UNREACHABLE_SECTION: return [self.unreachableHostsCollection count];
        default: return 0; // should never reach here
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Host Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    NagiosHost * currentHost = nil;
    
    // Configure the cell...
    switch ([indexPath section])
    {
        case HOST_OK_SECTION: currentHost = [self.upHostsCollection objectAtIndex:indexPath.row]; break;
        case HOST_DOWN_SECTION: currentHost = [self.downHostsCollection objectAtIndex:indexPath.row]; break;
        case HOST_PENDING_SECTION: currentHost = [self.pendingHostsCollection objectAtIndex:indexPath.row]; break;
        case HOST_UNREACHABLE_SECTION: currentHost = [self.unreachableHostsCollection objectAtIndex:indexPath.row]; break;
    }
    cell.textLabel.text = currentHost.hostName;
    cell.detailTextLabel.text = currentHost.pluginOutput;
    cell.imageView.image = [UIImage imageNamed:@"host.png"];
    
    return cell;
}

// Sets the sections header
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case HOST_OK_SECTION: return HOST_OK_HEADER;
        case HOST_DOWN_SECTION: return HOST_DOWN_HEADER;
        case HOST_PENDING_SECTION: return HOST_PENDING_HEADER;
        case HOST_UNREACHABLE_SECTION: return HOST_UNREACHABLE_HEADER;
        default: return @""; // should never reach here
    }
}

@end
