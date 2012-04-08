//
//  ServicesTableViewController.m
//  MobileNagios
//
//  Created by Jason Myerscough on 08/04/2012.
//  Copyright (c) 2012 Jason Myerscough. All rights reserved.
//

#import "ServicesTableViewController.h"
#import "NagiosHostService.h"

@interface ServicesTableViewController ()

@property (nonatomic, strong) NSArray *serviceCollection;

@property (nonatomic, strong) NSMutableArray *okServicesCollection;
@property (nonatomic, strong) NSMutableArray *warningServicesCollection;
@property (nonatomic, strong) NSMutableArray *criticalServicesCollection;
@property (nonatomic, strong) NSMutableArray *pendingServicesCollection;
@property (nonatomic, strong) NSMutableArray *unknownServicesCollection;

@end

@implementation ServicesTableViewController

@synthesize serviceCollection = _serviceCollection;
@synthesize okServicesCollection = _okServicesCollection;
@synthesize warningServicesCollection = _warningServicesCollection;
@synthesize criticalServicesCollection = _criticalServicesCollection;
@synthesize pendingServicesCollection = _pendingServicesCollection;
@synthesize unknownServicesCollection = _unknownServicesCollection;

- (void)setHostCollection:(NSArray *)serviceCollection
{
    self.serviceCollection = serviceCollection;
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.serviceCollection count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Services Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    NagiosHostService *service = [self.serviceCollection objectAtIndex:indexPath.row];
    
    // Configure the cell...
    cell.textLabel.text = service.serviceDescription;
    cell.detailTextLabel.text = service.pluginOutput;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO Segue to another view.
}

@end
