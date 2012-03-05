//
//  NagiosWebServiceReader.m
//  MobileNagios
//
//  Created by Jason Myerscough on 04/03/2012.
//  Copyright (c) 2012 Jason Myerscough. All rights reserved.
//

#import "NagiosWebServiceReader.h"

@interface NagiosWebServiceReader () <NSURLConnectionDelegate>

@property (nonatomic, strong) NSMutableData *dataBuffer;
@property (nonatomic) long expectedDataLength;
@property (nonatomic) long remainingBytes;
@end

@implementation NagiosWebServiceReader

@synthesize url = _url;
@synthesize lastError = _lastError;
@synthesize dataBuffer = _dataBuffer;
@synthesize expectedDataLength = _expectedDataLength;
@synthesize remainingBytes = _remainingBytes;

#pragma mark Public API


- (id)initWithURL:(NSURL *)url
{
    self = [self init];
    self.url = url;
    return self;    
}

- (void)retrieveNagiosStatus
{
    NSURLRequest *request = [NSURLRequest requestWithURL:self.url 
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:REQUEST_TIMEOUT];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request 
                                                                  delegate:self];
    
    if (connection)
    {
        self.dataBuffer = [NSMutableData data];
        [self.dataBuffer setLength:0];
    }
    else
    {
        //report an error to the end user.
    }
}

#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection *) didReceiveData:(NSData *)data
{
    NSLog(@"didReceiveData=%@", data);
    
    // data received from the web server is appended to the member variable/property
    [self.dataBuffer appendData:data];  
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.expectedDataLength = [response expectedContentLength];
    [self.dataBuffer setLength:0];
    
    NSLog(@"didReceiveResponse: expectedDataLength=%ld", self.expectedDataLength);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"connectionDidFinishLoading called.");
    
    // the data needs to be processed now that it has been received from the server.
    // xml parser
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError=%@", error);
    
    // need to notify users an error occurred. May need to implement a
    // notification service.
    
    self.lastError = [error localizedDescription];
}

@end
