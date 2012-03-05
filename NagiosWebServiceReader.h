//
//  NagiosWebServiceReader.h
//  MobileNagios
//
//  Created by Jason Myerscough on 04/03/2012.
//  Copyright (c) 2012 Jason Myerscough. All rights reserved.
//

#import <Foundation/Foundation.h>

#define REQUEST_TIMEOUT 60.0    // request should time out after 60 seconds.

@interface NagiosWebServiceReader : NSObject

- (void)retrieveTactialData;

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSString *lastError;

@end
