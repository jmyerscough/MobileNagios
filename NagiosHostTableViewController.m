//
//  NagiosHostTableViewController.m
//  MobileNagios
//
//  Created by Jason Myerscough on 11/03/2012.
//  Copyright (c) 2012 Jason Myerscough. All rights reserved.
//

#import "NagiosHostTableViewController.h"
#import "NagiosHost.h"
#import "NagiosWebServiceReader.h"
#import "SettingsViewController.h"  // the nagios address key is declared here

@interface NagiosHostTableViewController ()

@end

@implementation NagiosHostTableViewController

@synthesize hostCollection = _hostCollection;

-(void) setHostCollection:(NSArray *)hostCollection
{
    if (_hostCollection != hostCollection)
    {
        _hostCollection = hostCollection;
        [self.tableView reloadData];    // reload the view everytime the data module is changed.
    }
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)refreshButtonClicked:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults objectForKey:NAGIOS_ADDRESS_KEY])
    {
        // retrieve the data from the web server.
        NagiosWebServiceReader *nagiosService = [[NagiosWebServiceReader alloc] initWithURL:
                                                 [[NSURL alloc] initWithString:[defaults objectForKey:NAGIOS_ADDRESS_KEY]]];
        self.hostCollection =  [nagiosService retrieveNagiosStatusAndBlock];
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.hostCollection count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Host Information";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    NagiosHost *host = [self.hostCollection objectAtIndex:indexPath.row];
    cell.textLabel.text = host.hostName;
    cell.detailTextLabel.text = host.pluginOutput;
    
    return cell;
}

@end
