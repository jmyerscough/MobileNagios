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
    NSDictionary *hosts = [self.nagiosService getHosts];
    NSEnumerator *enumerator = [hosts keyEnumerator];
    NSString *key;
    
    while ((key = [enumerator nextObject]))
    {
        NagiosHost *currentHost = [[self.nagiosService getHosts] objectForKey:key];
        
        NSLog(@"---------------");
        NSLog(@"currentHost: %@", currentHost.hostName);
        for (int idx=0; idx < [currentHost.services count]; idx++)
        {
            NagiosHostService *service = [currentHost.services objectAtIndex:idx];
            NSLog(@"-- ServiceName: %@", service.serviceDescription);
        }
    }
}

@end
