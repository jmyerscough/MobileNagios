//
//  ServicesTableViewController.m
//  MobileNagios
//
//  Created by Jason Myerscough on 08/04/2012.
//  Copyright (c) 2012 Jason Myerscough. All rights reserved.
//

#import "ServicesTableViewController.h"
#import "NagiosHostService.h"

#define SERVICE_SECTION_COUNT          5

#define SERVICE_OK_SECTION             0       
#define SERVICE_DOWN_SECTION           1
#define SERVICE_CRITICAL_SECTION       2
#define SERVICE_PENDING_SECTION        3
#define SERVICE_UNKNOWN_SECTION        4

#define SERVICE_OK_HEADER             @"Ok"       
#define SERVICE_DOWN_HEADER           @"Down"
#define SERVICE_PENDING_HEADER        @"Pending"
#define SERVICE_CRITICAL_HEADER       @"Critical"
#define SERVICE_UNKNOWN_HEADER        @"Unknown"

@interface ServicesTableViewController ()
@property (nonatomic, strong) NSMutableArray *okServicesCollection;
@property (nonatomic, strong) NSMutableArray *warningServicesCollection;
@property (nonatomic, strong) NSMutableArray *criticalServicesCollection;
@property (nonatomic, strong) NSMutableArray *pendingServicesCollection;
@property (nonatomic, strong) NSMutableArray *unknownServicesCollection;
@end

@implementation ServicesTableViewController

@synthesize okServicesCollection = _okServicesCollection;
@synthesize warningServicesCollection = _warningServicesCollection;
@synthesize criticalServicesCollection = _criticalServicesCollection;
@synthesize pendingServicesCollection = _pendingServicesCollection;
@synthesize unknownServicesCollection = _unknownServicesCollection;

- (void)setHostCollection:(NSArray *)serviceCollection
{
    if (!self.okServicesCollection) self.okServicesCollection = [[NSMutableArray alloc] init];
    if (!self.warningServicesCollection) self.warningServicesCollection = [[NSMutableArray alloc] init];
    if (!self.criticalServicesCollection) self.criticalServicesCollection = [[NSMutableArray alloc] init];
    if (!self.pendingServicesCollection) self.pendingServicesCollection = [[NSMutableArray alloc] init];
    if (!self.unknownServicesCollection) self.unknownServicesCollection = [[NSMutableArray alloc] init];
    
    // remove all elements from the status arrays
    [self.okServicesCollection removeAllObjects];
    [self.warningServicesCollection removeAllObjects];
    [self.criticalServicesCollection removeAllObjects];
    [self.pendingServicesCollection removeAllObjects];    
    [self.unknownServicesCollection removeAllObjects];
    
    // add the services to the different status arrays
    for (int idx = 0; idx < [serviceCollection count]; idx++)
    {
        NagiosHostService *service = [serviceCollection objectAtIndex:idx];
        
        switch (service.currentState)
        {
            case NagiosServiceOk: [self.okServicesCollection addObject:service]; break;
            case NagiosServiceWarning: [self.warningServicesCollection addObject:service]; break;
            case NagiosServiceCrticial: [self.criticalServicesCollection addObject:service]; break;
            case NagiosServicePending: [self.pendingServicesCollection addObject:service]; break;
            case NagiosServiceUnknown: [self.unknownServicesCollection addObject:service]; break;
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SERVICE_SECTION_COUNT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case SERVICE_OK_SECTION : return [self.okServicesCollection count];
        case SERVICE_DOWN_SECTION: return [self.warningServicesCollection count];
        case SERVICE_CRITICAL_SECTION: return [self.criticalServicesCollection count];
        case SERVICE_PENDING_SECTION: return [self.pendingServicesCollection count];
        case SERVICE_UNKNOWN_SECTION: return [self.unknownServicesCollection count];
        default: return 0; // should never reach here
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Services Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    NagiosHostService *service = nil;
    
    switch (indexPath.section)
    {
        case SERVICE_OK_SECTION : service = [self.okServicesCollection objectAtIndex:indexPath.row]; break;
        case SERVICE_DOWN_SECTION: service = [self.warningServicesCollection objectAtIndex:indexPath.row]; break;
        case SERVICE_CRITICAL_SECTION: service = [self.criticalServicesCollection objectAtIndex:indexPath.row]; break;
        case SERVICE_PENDING_SECTION: service = [self.pendingServicesCollection objectAtIndex:indexPath.row]; break;
        case SERVICE_UNKNOWN_SECTION: service = [self.unknownServicesCollection objectAtIndex:indexPath.row]; break;
        default: return 0; // should never reach here
    }
    
    // Configure the cell...
    cell.textLabel.text = service.serviceDescription;
    cell.detailTextLabel.text = service.pluginOutput;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case SERVICE_OK_SECTION : return SERVICE_OK_HEADER;
        case SERVICE_DOWN_SECTION: return SERVICE_DOWN_HEADER;
        case SERVICE_CRITICAL_SECTION: return SERVICE_CRITICAL_HEADER;
        case SERVICE_PENDING_SECTION: return SERVICE_PENDING_HEADER;
        case SERVICE_UNKNOWN_SECTION: return SERVICE_UNKNOWN_HEADER;
        default: return @""; // should never reach here
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO Segue to another view.
}

@end
