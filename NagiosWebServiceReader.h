//
//  NagiosWebServiceReader.h
//  MobileNagios
//
//  Created by Jason Myerscough on 04/03/2012.
//  Copyright (c) 2012 Jason Myerscough. All rights reserved.
//

#import <Foundation/Foundation.h>

#define REQUEST_TIMEOUT 60.0    // request should time out after 60 seconds.

#define HOST_TAG_NAME   @"host"

// TODO store expected host tags in a map/dictionary

@interface NagiosWebServiceReader : NSObject

- (id)initWithURL:(NSURL *)url;

- (void)retrieveNagiosStatus;

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSString *lastError;

@end
