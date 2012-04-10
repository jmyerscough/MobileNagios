//
//  ServiceDetailViewController.h
//  MobileNagios
//
//  Created by Jason Myerscough on 10/04/2012.
//  Copyright (c) 2012 Jason Myerscough. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NagiosHostService;

@interface ServiceDetailViewController : UITableViewController
- (void)setCurrentService:(NagiosHostService *)service;
@end
