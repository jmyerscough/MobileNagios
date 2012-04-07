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
#import "SettingsViewController.h"  // the nagios address key is declared here
#import "HostsViewController.h"

@interface TacticalTableViewController ()

@property (nonatomic, strong) NagiosWebServiceReader *nagiosService;
@property (nonatomic, strong) NSTimer *parserTimeout;
@property (nonatomic, strong) NSArray *hostCollection;

@end

// defines the number of sections in the table view.
#define TACTICAL_SECTION_COUNT              3

// defines the number of rows in the host and service sections
#define HOST_ROW_COUNT_IN_TACTICAL_VIEW     4       
#define SERVICE_ROW_COUNT_IN_TACTICAL_VIEW  5

// section ids
#define NETWORK_HEALTH_SECTION              0       
#define HOSTS_SECTION                       1       
#define SERVICES_SECTION                    2  

// row ids for the host section
#define HOST_OK_INDEX                       0       
#define HOST_DOWN_INDEX                     1
#define HOST_PENDING_INDEX                  2
#define HOST_UNREACHABLE_INDEX              3

#define SERVICE_OK                          0
#define SERVICE_WARNING                     1
#define SERVICE_PENDING                     3
#define SERVICE_CRITICAL                    2
#define SERVICE_UNKNOWN                     4

// table view headers
#define HEALTH_STATUS_HEADER            @"Network Health"
#define HOST_SUMMARY_HEADER             @"Hosts Summary"
#define SERVICES_SUMMARY_HEADER         @"Service Summary"

#define PARSER_TIMEOUT                      10.0

#define HOST_TAB_INDEX                      1

@implementation TacticalTableViewController

@synthesize nagiosService = _nagiosService;
@synthesize hostCollection = _hostCollection;
@synthesize parserTimeout = _parserTimeout;

-(void) setHostCollection:(NSArray *)hostCollection
{
    if (_hostCollection != hostCollection)
    {
        _hostCollection = hostCollection;
        [self.tableView reloadData];    // reload the view everytime the data module is changed.

        // pass the host information to the host view controller The host view controller is embedded in
        // an Navigation controller.
        UINavigationController *navigstionVC = [[self.tabBarController viewControllers] objectAtIndex:HOST_TAB_INDEX];
        HostsViewController * hostVC = [[navigstionVC viewControllers] objectAtIndex:0];
        NSLog(@"%@", hostVC);
        [hostVC setHostCollection:self.hostCollection];
    }
}

- (void)parserDidTimeout
{
    
}

#pragma mark Actions

- (IBAction)refreshData:(UIBarButtonItem *)sender
{
    NSLog(@"reload nagios data");
    
    // Start the timer, which will be used to abort the parser
    self.parserTimeout = [NSTimer timerWithTimeInterval:PARSER_TIMEOUT 
                                                 target:self
                                               selector:@selector(parserDidTimeout)
                                               userInfo:nil
                                                repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:self.parserTimeout forMode:NSDefaultRunLoopMode];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults objectForKey:NAGIOS_ADDRESS_KEY])
    {
        // retrieve the data from the web server.
        self.nagiosService = [[NagiosWebServiceReader alloc] initWithURL:
                                                 [[NSURL alloc] initWithString:[defaults objectForKey:NAGIOS_ADDRESS_KEY]]];
        self.hostCollection =  [self.nagiosService retrieveNagiosStatusAndBlock];
    }
    else
    {
        UIAlertView *errorMessage = [[UIAlertView alloc] initWithTitle:@"No valid server address"
                                                               message:@"Please check the application settings and enter the webserver's URL" 
                                                              delegate:nil
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:nil];
        [errorMessage show];
    }
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
        case SERVICES_SECTION: return SERVICE_ROW_COUNT_IN_TACTICAL_VIEW;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Tactical Table Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    // TODO refactor code. Create methods for each section.
    switch (indexPath.section)
    {
        case NETWORK_HEALTH_SECTION:
            [self prepareTableCellForNetworkHealth:cell atIndex:indexPath];
            break;
        case HOSTS_SECTION:
            [self prepareTableCellForHost:cell atIndex:indexPath];
            break;
        case SERVICES_SECTION:
            [self prepareTableCellForService:cell atIndex:indexPath];                                
            break;
    }
    
    
    return cell;
}

- (void)prepareTableCellForNetworkHealth:(UITableViewCell *)cell atIndex:(NSIndexPath *)indexPath
{
    if (!indexPath.row)
    {
        int upHostCount = 0;
        float status = 0;
        
        for (int idx=0; idx < [self.hostCollection count]; idx++)
        {
            NagiosHost *host = [self.hostCollection objectAtIndex:idx];
            if (host.currentState == NagiosHostUp)
                ++upHostCount;
        }
        
        NSLog(@"hostCollection.count=%d, upHostCount=%d", [self.hostCollection count], upHostCount);
        if (self.hostCollection && upHostCount > 0)
        {
            status = ((float)upHostCount / [self.hostCollection count]) * 100.0;
        }
        else
        {
            status = 0;
        }
        
        cell.textLabel.text = @"Hosts";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f%\%", status];
        //cell.imageView.image = [UIImage imageNamed:@"mycomputer.png"];
        cell.imageView.image = [UIImage imageNamed:@"host.png"];
    }
    else
    {
        cell.textLabel.text = @"Services";
        cell.detailTextLabel.text = @"100%";    // TODO implement service information
        cell.imageView.image = [UIImage imageNamed:@"misc.png"];
    }
}

- (void)prepareTableCellForHost:(UITableViewCell *)cell atIndex:(NSIndexPath *)indexPath
{
    int okCount = 0, downCount = 0, pendingCount = 0, unreachableCount = 0;
    
    for (int idx = 0; idx < [self.hostCollection count]; idx++)
    {
        NagiosHost *host = [self.hostCollection objectAtIndex:idx];
        
        switch (host.currentState)
        {
            case NagiosHostDown: ++downCount; break;
            case NagiosHostUp: ++okCount; break;
            case NagiosHostUnreachable: break;
            case NagiosHostPending: break;
        }
    }
    
    switch (indexPath.row)
    {
        case HOST_OK_INDEX:
            cell.textLabel.text = @"UP";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", okCount];
            cell.imageView.image = [UIImage imageNamed:@"System-Security-Firewall-ON-icon.png"];
            break;
        case HOST_DOWN_INDEX:
            cell.textLabel.text = @"Down";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", downCount];
            cell.imageView.image = [UIImage imageNamed:@"System-Security-Firewall-OFF-icon.png"];
            break;
        case HOST_PENDING_INDEX:
            cell.textLabel.text = @"Pending";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", pendingCount];
            cell.imageView.image = [UIImage imageNamed:@"System-Security-Question-icon.png"];
            break;
        case HOST_UNREACHABLE_INDEX:
            cell.textLabel.text = @"Unreachable";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", unreachableCount];
            cell.imageView.image = [UIImage imageNamed:@"System-Security-Warning-icon.png.png"];
            break;                    
        default:
            break;
    }
}

- (void)prepareTableCellForService:(UITableViewCell *)cell atIndex:(NSIndexPath *)indexPath
{
    int serviceok = 0, serviceWarning = 0, servicePending = 0, serviceCritical = 0, serviceUnknown = 0;
    
    for (int idx=0; idx < [self.hostCollection count]; idx++)
    {
        NagiosHost *host = [self.hostCollection objectAtIndex:idx];
        for (int j=0; j < [host.services count]; j++)
        {
            NagiosHostService *service = [host.services objectAtIndex:j];
            
            switch (service.currentState)
            {
                case NagiosServiceOk:
                    ++serviceok;
                    break;
                case NagiosServiceWarning:
                    break;
                case NagiosServiceCrticial:
                    break;
                case NagiosServicePending:
                    break;
                case NagiosServiceUnknown:
                    break;
            }
        }
    }
    
    switch (indexPath.row)
    {
        case SERVICE_OK:
            cell.textLabel.text = @"OK";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", serviceok];
            cell.imageView.image = [UIImage imageNamed:@"System-Security-Firewall-ON-icon.png"];
            break;
        case SERVICE_CRITICAL:
            cell.textLabel.text = @"Critical";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", serviceCritical];
            cell.imageView.image = [UIImage imageNamed:@"System-Security-Firewall-OFF-icon.png"];
            break;
        case SERVICE_WARNING:
            cell.textLabel.text = @"Warning";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", serviceWarning];
            cell.imageView.image = [UIImage imageNamed:@"System-Security-Warning-icon.png"];
            break;
        case SERVICE_PENDING:
            cell.textLabel.text = @"Pending";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", servicePending];
            cell.imageView.image = [UIImage imageNamed:@"System-Security-Question-icon.png"];
            break;
        case SERVICE_UNKNOWN:
            cell.textLabel.text = @"Unknown";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", serviceUnknown];
            cell.imageView.image = [UIImage imageNamed:@"System-Security-Question-icon.png"];
            break;
        default:
            break;
    }
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
        case SERVICES_SECTION:
            return SERVICES_SUMMARY_HEADER;
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
