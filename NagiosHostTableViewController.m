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
    // retrieve the data from the web server.
    NagiosWebServiceReader *nagiosService = [[NagiosWebServiceReader alloc] initWithURL:
                                             [[NSURL alloc] initWithString:@"http://192.168.44.130/status/"]];
    self.hostCollection =  [nagiosService retrieveNagiosStatusAndBlock];   
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

#pragma mark - Table view delegate

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
