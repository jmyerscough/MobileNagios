//
//  NagiosWebServiceReader.m
//  MobileNagios
//
//  Created by Jason Myerscough on 04/03/2012.
//  Copyright (c) 2012 Jason Myerscough. All rights reserved.
//

#import "NagiosWebServiceReader.h"

// Private class method & property declarations.
@interface NagiosWebServiceReader () <NSURLConnectionDelegate, NSXMLParserDelegate>     // Delegate interfaces have been declared private because the 
                                                                                        // public interface does not need to know these protocols are
                                                                                        // implemented.

// Parses the status XML file and instantiates a collection of hosts
// and services.
- (void)parseStatusData:(NSData *)statusData;

@property (nonatomic, strong) NSMutableData *dataBuffer;  // stores the data sent from the webserver.
@property (nonatomic) long expectedDataLength;            // stores the length of data to be expected from the web server.

@property (nonatomic) BOOL processingHost;
@end

@implementation NagiosWebServiceReader

@synthesize url = _url;
@synthesize lastError = _lastError;
@synthesize dataBuffer = _dataBuffer;
@synthesize expectedDataLength = _expectedDataLength;
@synthesize processingHost = _processingHost;

#pragma mark Public API


- (id)initWithURL:(NSURL *)url
{
    self = [self init];
    self.url = url;
    self.processingHost = NO;
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
    
    NSString * s = [[NSString alloc] initWithData:self.dataBuffer encoding:NSUTF8StringEncoding];
    
    NSLog(@"%@", s);
    
    //if (self.expectedDataLength > 0)
    // the data needs to be processed now that it has been received from the server.
        [self parseStatusData:[self.dataBuffer copy]];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError=%@", error);
    
    // need to notify users an error occurred. May need to implement a
    // notification service.
    
    self.lastError = [error localizedDescription];
}

#pragma Private API

- (void)parseStatusData:(NSData *)statusData
{
    BOOL success;
    //NSXMLParser *statusXMLParser = [[NSXMLParser alloc] initWithData:statusData];
    NSXMLParser *statusXMLParser = [[NSXMLParser alloc] initWithContentsOfURL:[[NSURL alloc] initWithString:@"http://192.168.44.130/status.php" ]];
    
    statusXMLParser.delegate = self;
    success = [statusXMLParser parse];
    
    if (!success)
    {
        // notify caller of error
        //NSError *error = [statusXMLParser parserError];
        //NSLog(@"error=%@", error);
    }
}

#pragma NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:HOST_TAG_NAME])
    {
        self.processingHost = YES;
        // TODO create an instance of NagiosHost
        NSLog(@"Host node found");
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:HOST_TAG_NAME])
        self.processingHost = NO;
}

// read the data between the tags
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    //NSLog(@"string=%@", string);
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    NSString *s = [NSString stringWithFormat:@"Error %i, Description: %@, Line: %i, Column: %i", [parseError code],
     [[parser parserError] localizedDescription], [parser lineNumber],
     [parser columnNumber]];
    NSLog(@"%@", s);    
}

@end
