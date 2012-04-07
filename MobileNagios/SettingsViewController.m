//
//  SettingsViewController.m
//  MobileNagios
//
//  Created by Jason Myerscough on 07/04/2012.
//  Copyright (c) 2012 Jason Myerscough. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController
@synthesize nagiosServerAddress;

- (void)viewDidLoad
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:NAGIOS_ADDRESS_KEY])
        self.nagiosServerAddress.text = [defaults objectForKey:NAGIOS_ADDRESS_KEY];
}

- (IBAction)addressDoneEditing:(id)sender
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    
    if ([self.nagiosServerAddress text] != nil)
    {
        // write the address information to user default settings file.
        [defaults setObject:[self.nagiosServerAddress text] forKey:NAGIOS_ADDRESS_KEY];
        [defaults synchronize];    // synchronise the user default database
    }
    // make the keyboard disappear.
    [self.nagiosServerAddress resignFirstResponder];
}

@end
