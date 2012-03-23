//
//  ViewController.m
//  MobileNagios
//
//  Created by Jason Myerscough on 04/03/2012.
//  Copyright (c) 2012 Jason Myerscough. All rights reserved.
//

#import "ViewController.h"
#import "NagiosWebServiceReader.h"
#import "NagiosHost.h"
#import "NagiosHostService.h"

@interface ViewController ()

@property (nonatomic, strong) NagiosWebServiceReader *nagiosService;

@end

@implementation ViewController

@synthesize nagiosService=_nagiosService;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.nagiosService = [[NagiosWebServiceReader alloc] init];
                                                        
    self.nagiosService.url = [[NSURL alloc] initWithString:@"http://192.168.44.130/status/"];
    [self.nagiosService retrieveNagiosStatus];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (IBAction)buttonClicked 
{
    // iterate the NSDictionary collection
    NSArray *hosts = [self.nagiosService getHosts];
    
    for (int idx=0; idx < [hosts count]; idx++)
    {
        NagiosHost *currentHost = [hosts objectAtIndex:idx];
        
        NSLog(@"---------------");
        NSLog(@"currentHost: %@", currentHost.hostName);
        for (int jdx=0; jdx < [currentHost.services count]; jdx++)
        {
            NagiosHostService *service = [currentHost.services objectAtIndex:jdx];
            NSLog(@"-- ServiceName: %@", service.serviceDescription);
        }
    }
}

@end
