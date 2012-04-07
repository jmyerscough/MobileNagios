//
//  SettingsViewController.h
//  MobileNagios
//
//  Created by Jason Myerscough on 07/04/2012.
//  Copyright (c) 2012 Jason Myerscough. All rights reserved.
//

#import <UIKit/UIKit.h>


#define NAGIOS_ADDRESS_KEY  @"NAGIOS_SERVER_ADDRESS"

@interface SettingsViewController : UIViewController

// will save the nagios server address to the settings file.
- (IBAction)addressDoneEditing:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *nagiosServerAddress;
@end
