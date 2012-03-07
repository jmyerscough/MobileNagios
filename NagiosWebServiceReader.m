//
//  NagiosWebServiceReader.m
//  MobileNagios
//
//  Created by Jason Myerscough on 04/03/2012.
//  Copyright (c) 2012 Jason Myerscough. All rights reserved.
//

#import "NagiosWebServiceReader.h"
#import "NagiosHost.h"

// Private class method & property declarations.
@interface NagiosWebServiceReader () <NSURLConnectionDelegate, NSXMLParserDelegate>     // Delegate interfaces have been declared private because the 
                                                                                        // public interface does not need to know these protocols are
                                                                                        // implemented.

- (void)parseStatusData:(NSData *)statusData; // Parses the status XML file and instantiates a collection of hosts and services.
- (void)initHostTags;    // initialises the dictionary that stores the host tags
- (void)initServiceTags; // initialises the dictionary that stores the service tags
- (void)setCurrentHostTagValue:(NSString *)tagName withTagData:(NSString *)tagData; // sets one of the NagiosHost instance's properties depending
                                                                                    // on the value of tagName
- (void)setCurrentServiceTagValue:(NSString *)tagName withTagData:(NSString *)tagData;

@property (nonatomic, strong) NSMutableData *dataBuffer;            // stores the data sent from the webserver.
@property (nonatomic) long expectedDataLength;                      // stores the length of data to be expected from the web server.
@property (nonatomic) BOOL processingHost;                          // indicates whether a host entity is being processed.
@property (nonatomic) BOOL processingService;
@property (nonatomic, strong) NSURLRequest *request;                // represents the current HTTP request
@property (nonatomic, strong) NSDictionary *hostTags;               // stores the hosts member tag names. 
@property (nonatomic, strong) NSDictionary *serviceTags;            // stores the services member tag names.
@property (nonatomic, strong) NagiosHost *currentHost;              // represents the current host being processed by the parser
@property (nonatomic, strong) NagiosHostService *currentHostService;
@property (nonatomic, strong) NSMutableString *currentTagData;      // stores the data between the current xml tag
@property (nonatomic, strong) NSMutableDictionary *hostCollection;  // contains the collection of hosts.

@end

@implementation NagiosWebServiceReader

@synthesize url = _url;
@synthesize lastError = _lastError;
@synthesize dataBuffer = _dataBuffer;
@synthesize expectedDataLength = _expectedDataLength;
@synthesize processingHost = _processingHost;
@synthesize processingService = _processingService;
@synthesize request = _request;
@synthesize hostTags = _hostTags;
@synthesize serviceTags = _serviceTags;
@synthesize currentHost = _currentHost;
@synthesize currentHostService = _currentHostService;
@synthesize currentTagData;
@synthesize hostCollection = _hostCollection;

#pragma mark Public API

- (id)initWithURL:(NSURL *)url
{
    self = [self init];
    self.url = url;
    self.processingHost = NO;
    self.processingService = NO;
    return self;    
}

- (void)retrieveNagiosStatus
{
    NSURLRequest * request = [NSURLRequest requestWithURL:self.url];
    
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    
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

- (NSDictionary *)getHosts
{
    return [self.hostCollection copy];
}


#pragma mark Private API

- (void)initHostTags
{
    int idx = 0;
    // the dictionary is used while parsing the data. The dictionary will ensure the
    // parsing code is cleaner.
    NSMutableDictionary *hostTags = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithInt:idx++], @"host_name",
                                     [NSNumber numberWithInt:idx++], @"modified_attributes",
                                     [NSNumber numberWithInt:idx++], @"check_command",
                                     [NSNumber numberWithInt:idx++], @"check_period",
                                     [NSNumber numberWithInt:idx++], @"notification_period",
                                     [NSNumber numberWithInt:idx++], @"check_interval",
                                     [NSNumber numberWithInt:idx++], @"retry_interval",
                                     [NSNumber numberWithInt:idx++], @"event_handler",
                                     [NSNumber numberWithInt:idx++], @"has_been_checked",
                                     [NSNumber numberWithInt:idx++], @"should_be_scheduled",
                                     [NSNumber numberWithInt:idx++], @"check_execution_time",
                                     [NSNumber numberWithInt:idx++], @"check_latency",
                                     [NSNumber numberWithInt:idx++], @"check_type",
                                     [NSNumber numberWithInt:idx++], @"current_state",
                                     [NSNumber numberWithInt:idx++], @"last_hard_state",
                                     [NSNumber numberWithInt:idx++], @"last_event_id",
                                     [NSNumber numberWithInt:idx++], @"current_event_id",
                                     [NSNumber numberWithInt:idx++], @"current_problem_id",
                                     [NSNumber numberWithInt:idx++], @"last_problem_id",
                                     [NSNumber numberWithInt:idx++], @"plugin_output",
                                     [NSNumber numberWithInt:idx++], @"long_plugin_output",
                                     [NSNumber numberWithInt:idx++], @"performance_data",
                                     [NSNumber numberWithInt:idx++], @"last_check",
                                     [NSNumber numberWithInt:idx++], @"next_check",
                                     [NSNumber numberWithInt:idx++], @"check_options",
                                     [NSNumber numberWithInt:idx++], @"current_attempt",
                                     [NSNumber numberWithInt:idx++], @"max_attempts",
                                     [NSNumber numberWithInt:idx++], @"state_type",
                                     [NSNumber numberWithInt:idx++], @"last_state_change",
                                     [NSNumber numberWithInt:idx++], @"last_hard_state_change",
                                     [NSNumber numberWithInt:idx++], @"last_time_up",
                                     [NSNumber numberWithInt:idx++], @"last_time_down",
                                     [NSNumber numberWithInt:idx++], @"last_time_unreachable",
                                     [NSNumber numberWithInt:idx++], @"last_notification",
                                     [NSNumber numberWithInt:idx++], @"next_notification",
                                     [NSNumber numberWithInt:idx++], @"no_more_notifications",
                                     [NSNumber numberWithInt:idx++], @"current_notification_number",
                                     [NSNumber numberWithInt:idx++], @"current_notification_id",
                                     [NSNumber numberWithInt:idx++], @"notifications_enabled",
                                     [NSNumber numberWithInt:idx++], @"problem_has_been_acknowledged",
                                     [NSNumber numberWithInt:idx++], @"acknowledgement_type",
                                     [NSNumber numberWithInt:idx++], @"active_checks_enabled",
                                     [NSNumber numberWithInt:idx++], @"passive_checks_enabled",
                                     [NSNumber numberWithInt:idx++], @"event_handler_enabled",
                                     [NSNumber numberWithInt:idx++], @"flap_detection_enabled",
                                     [NSNumber numberWithInt:idx++], @"failure_prediction_enabled",
                                     [NSNumber numberWithInt:idx++], @"process_performance_data",
                                     [NSNumber numberWithInt:idx++], @"obsess_over_host",
                                     [NSNumber numberWithInt:idx++], @"last_update",
                                     [NSNumber numberWithInt:idx++], @"is_flapping",
                                     [NSNumber numberWithInt:idx++], @"percent_state_change",
                                     [NSNumber numberWithInt:idx++], @"scheduled_downtime_depth", nil];
    
    self.hostTags = [hostTags copy]; 
}

- (void)initServiceTags
{
    int idx = 0;
    // the dictionary is used while parsing the data. The dictionary will ensure the
    // parsing code is cleaner.
    NSMutableDictionary *serviceTags = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithInt:idx++], @"host_name",
                                       [NSNumber numberWithInt:idx++], @"service_description",
                                       [NSNumber numberWithInt:idx++], @"modified_attributes",
                                       [NSNumber numberWithInt:idx++], @"check_command",
                                       [NSNumber numberWithInt:idx++], @"check_period",
                                       [NSNumber numberWithInt:idx++], @"notification_period",
                                       [NSNumber numberWithInt:idx++], @"check_interval",
                                       [NSNumber numberWithInt:idx++], @"retry_interval",
                                       [NSNumber numberWithInt:idx++], @"event_handler",
                                       [NSNumber numberWithInt:idx++], @"has_been_checked",
                                       [NSNumber numberWithInt:idx++], @"should_be_scheduled",
                                       [NSNumber numberWithInt:idx++], @"check_execution_time",
                                       [NSNumber numberWithInt:idx++], @"check_latency",
                                       [NSNumber numberWithInt:idx++], @"check_type",
                                       [NSNumber numberWithInt:idx++], @"current_state",
                                       [NSNumber numberWithInt:idx++], @"last_hard_state",
                                       [NSNumber numberWithInt:idx++], @"last_event_id",
                                       [NSNumber numberWithInt:idx++], @"current_event_id",
                                       [NSNumber numberWithInt:idx++], @"current_problem_id",
                                       [NSNumber numberWithInt:idx++], @"last_problem_id",
                                       [NSNumber numberWithInt:idx++], @"current_attempt",
                                       [NSNumber numberWithInt:idx++], @"max_attempts",
                                       [NSNumber numberWithInt:idx++], @"state_type",
                                       [NSNumber numberWithInt:idx++], @"last_state_change",
                                       [NSNumber numberWithInt:idx++], @"last_hard_state_change",
                                       [NSNumber numberWithInt:idx++], @"last_time_ok",
                                       [NSNumber numberWithInt:idx++], @"last_time_warning",
                                       [NSNumber numberWithInt:idx++], @"last_time_unknown",
                                       [NSNumber numberWithInt:idx++], @"last_time_critical",
                                       [NSNumber numberWithInt:idx++], @"plugin_output",
                                       [NSNumber numberWithInt:idx++], @"long_plugin_output",
                                       [NSNumber numberWithInt:idx++], @"performance_data",
                                       [NSNumber numberWithInt:idx++], @"last_check",
                                       [NSNumber numberWithInt:idx++], @"next_check",
                                       [NSNumber numberWithInt:idx++], @"check_options",
                                       [NSNumber numberWithInt:idx++], @"current_notification_number",
                                       [NSNumber numberWithInt:idx++], @"current_notification_id",
                                       [NSNumber numberWithInt:idx++], @"last_notification",
                                       [NSNumber numberWithInt:idx++], @"next_notification",
                                       [NSNumber numberWithInt:idx++], @"no_more_notifications",
                                       [NSNumber numberWithInt:idx++], @"notifications_enabled",
                                       [NSNumber numberWithInt:idx++], @"active_checks_enabled",
                                       [NSNumber numberWithInt:idx++], @"passive_checks_enabled",
                                       [NSNumber numberWithInt:idx++], @"event_handler_enabled",
                                       [NSNumber numberWithInt:idx++], @"problem_has_been_acknowledged",
                                       [NSNumber numberWithInt:idx++], @"acknowledgement_type",
                                       [NSNumber numberWithInt:idx++], @"flap_detection_enabled",
                                       [NSNumber numberWithInt:idx++], @"failure_prediction_enabled",
                                       [NSNumber numberWithInt:idx++], @"process_performance_data",
                                       [NSNumber numberWithInt:idx++], @"obsess_over_service",
                                       [NSNumber numberWithInt:idx++], @"last_update",
                                       [NSNumber numberWithInt:idx++], @"is_flapping",
                                       [NSNumber numberWithInt:idx++], @"percent_state_change",
                                       [NSNumber numberWithInt:idx++], @"scheduled_downtime_depth", nil];
    
    self.serviceTags = [serviceTags copy];
}

- (void)setCurrentHostTagValue:(NSString *)tagName withTagData:(NSString *)tagData
{
    NSNumber *currentHostTagId = [self.hostTags objectForKey:tagName];
    
    NSLog(@"currentId=%d", [currentHostTagId integerValue]);
    
    switch ([currentHostTagId integerValue])
    {
        case 0:
            self.currentHost.hostName = self.currentTagData;
            break;
        case 1:
            self.currentHost.modifiedAttributes = [self.currentTagData integerValue];
            break;
        case 2:
            self.currentHost.checkCommand = self.currentTagData;
            break;
        case 3:
            self.currentHost.checkPeriod = self.currentTagData;
            break;
        case 4:
            self.currentHost.notificationPeriod = self.currentTagData;
            break;
        case 5:
            self.currentHost.checkInterval = [self.currentTagData floatValue];
            break;
        case 6:
            self.currentHost.retryInterval = [self.currentTagData floatValue];
            break;
        case 7:
            self.currentHost.eventHandler = self.currentTagData;
            break;
        case 8:
            self.currentHost.hasBeenChecked = [self.currentTagData boolValue];
            break;
        case 9:
            self.currentHost.shouldBeScheduled = [self.currentTagData boolValue];
            break;
        case 10:
            self.currentHost.checkExecutionTime = [self.currentTagData floatValue];
            break;
        case 11:
            self.currentHost.checkLatency = [self.currentTagData floatValue];
            break;
        case 12:
            self.currentHost.checkType = [self.currentTagData integerValue];
            break;
        case 13:
            self.currentHost.currentState = [self.currentTagData integerValue];
            break;
        case 14:
            self.currentHost.lastHardState = [self.currentTagData integerValue];
            break;
        case 15:
            self.currentHost.lastEventId = [self.currentTagData integerValue];
            break;
        case 16:
            self.currentHost.currentEventId = [self.currentTagData integerValue];
            break;
        case 17:
            self.currentHost.currentProblemId = [self.currentTagData integerValue];
            break;
        case 18:
            self.currentHost.lastProblemId = [self.currentTagData integerValue];
            break;
        case 19:
            self.currentHost.pluginOutput = self.currentTagData;
            break;
        case 20:
            self.currentHost.longPluginOutput = self.currentTagData;
            break;
        case 21:
            self.currentHost.performanceData = self.currentTagData;
            break;
        case 22:
            // TODO: change this to a NSDate object
            self.currentHost.lastCheck = [self.currentTagData longLongValue];
            break;
        case 23:
            self.currentHost.nextCheck = [self.currentTagData longLongValue];
            break;
        case 24:
            self.currentHost.checkOptions = [self.currentTagData integerValue];
            break;
        case 25:
            self.currentHost.currentAttempt = [self.currentTagData integerValue];
            break;
        case 26:
            self.currentHost.maxAttempts = [self.currentTagData integerValue];
            break;
        case 27:
            self.currentHost.stateType = [self.currentTagData integerValue];
            break;
        case 28:
            self.currentHost.lastStateChange = [self.currentTagData longLongValue];
            break;
        case 29:
            self.currentHost.lastHardStateChange = [self.currentTagData longLongValue];
            break;
        case 30:
            self.currentHost.lastTimeUp = [self.currentTagData longLongValue];
            break;
        case 31:
            self.currentHost.lastTimeDown = [self.currentTagData longLongValue];
            break;
        case 32:
            self.currentHost.lastTimeUnreachable = [self.currentTagData longLongValue];
            break;
        case 33:
            self.currentHost.lastNotification = [self.currentTagData integerValue];
            break;
        case 34:
            self.currentHost.nextNotification = [self.currentTagData integerValue];
            break;
        case 35:
            self.currentHost.noMoreNotifications = [self.currentTagData boolValue];
            break;
        case 36:
            self.currentHost.currentNotificationNumber = [self.currentTagData integerValue];
            break;
        case 37:
            self.currentHost.currentNotificationId = [self.currentTagData integerValue];
            break;
        case 38:
            self.currentHost.notificationsEnabled = [self.currentTagData boolValue];
            break;
        case 39:
            self.currentHost.problemHasBeenAcknowledged = [self.currentTagData boolValue];
            break;
        case 40:
            self.currentHost.acknowledgementType = [self.currentTagData integerValue];
            break;
        case 41:
            self.currentHost.activeChecksEnabled = [self.currentTagData boolValue];
            break;
        case 42:
            self.currentHost.passiveChecksEnabled = [self.currentTagData boolValue];
            break;
        case 43:
            self.currentHost.eventHandlerEnabled = [self.currentTagData boolValue];
            break;
        case 44:
            self.currentHost.flapDetectionEnabled = [self.currentTagData boolValue];
            break;
        case 45:
            self.currentHost.failurePredictionEnabled = [self.currentTagData boolValue];
            break;
        case 46:
            self.currentHost.processPerformanceData = [self.currentTagData boolValue];
            break;
        case 47:
            self.currentHost.obsessOverHost = [self.currentTagData boolValue];
            break;
        case 48:
            self.currentHost.lastUpdate = [self.currentTagData longLongValue];
            break;
        case 49:
            self.currentHost.isFlapping = [self.currentTagData boolValue];
            break;
        case 50:
            self.currentHost.percentStateChange = [self.currentTagData floatValue];
            break;
        case 51:
            self.currentHost.scheduledDowntimeDepth = [self.currentTagData integerValue];
            break;
    }
}

- (void)setCurrentServiceTagValue:(NSString *)tagName withTagData:(NSString *)tagData
{
    NSNumber *currentServiceTagId = [self.serviceTags objectForKey:tagName];
    
    NSLog(@"currentId=%d", [currentServiceTagId integerValue]);
    
    switch ([currentServiceTagId integerValue])
    {
        case 0:
            break;
        case 1:
            break;
        case 2:
            break;
        case 3:
            break;
        case 4:
            break;
        case 5:
            break;
        case 6:
            break;
        case 7:
            break;
        case 8:
            break;
        case 9:
            break;
        case 10:
            break;
        case 11:
            break;
        case 12:
            break;
        case 13:
            break;
        case 14:
            break;
        case 15:
            break;
        case 16:
            break;
        case 17:
            break;
        case 18:
            break;
        case 19:
            break;
        case 20:
            break;
        case 21:
            break;
        case 22:
            break;
        case 23:
            break;
        case 24:
            break;
        case 25:
            break;
        case 26:
            break;
        case 27:
            break;
        case 28:
            break;
        case 29:
            break;
        case 30:
            break;
        case 31:
            break;
        case 32:
            break;
        case 33:
            break;
        case 34:
            break;
        case 35:
            break;
        case 36:
            break;
        case 37:
            break;
        case 38:
            break;
        case 39:
            break;
        case 40:
            break;
        case 41:
            break;
        case 42:
            break;
        case 43:
            break;
        case 44:
            break;
        case 45:
            break;
        case 46:
            break;
        case 47:
            break;
        case 48:
            break;
        case 49:
            break;
        case 50:
            break;
        case 51:
            break;
    }
}

#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)data
{
    NSLog(@"didReceiveData=%@", data);
    
    // data received from the web server is appended to the member variable/property
    [self.dataBuffer appendData:data];  
}

- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response
{
    self.expectedDataLength = [response expectedContentLength];
    [self.dataBuffer setLength:0];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"connectionDidFinishLoading called.");
    
    NSString * s = [[NSString alloc] initWithData:self.dataBuffer encoding:NSUTF8StringEncoding];
    
    NSLog(@"%@", s);
    
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
    NSXMLParser *statusXMLParser = [[NSXMLParser alloc] initWithData:statusData];
    
    self.hostCollection = [[NSMutableDictionary alloc] init];
    
    [self initHostTags];
    [self initServiceTags];
    
    statusXMLParser.delegate = self;
    success = [statusXMLParser parse];
    
    if (!success)
    {
        // notify caller of error
        NSError *error = [statusXMLParser parserError];
        NSLog(@"error=%@", error);
    }
}

#pragma NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
    self.currentTagData = [[NSMutableString alloc] initWithString:@""];
    
    if ([elementName isEqualToString:HOST_TAG_NAME])
    {
        self.processingHost = YES;
        self.currentHost = [[NagiosHost alloc] init];
        self.currentHost.services = [[NSMutableArray alloc] init];
    }
    else if ([elementName isEqualToString:SERVICE_TAG_NAME])
    {
        self.processingService = YES;
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:HOST_TAG_NAME])
    {
        [self.hostCollection setObject:self.currentHost forKey:self.currentHost.hostName]; // add the host to the dictionary.
        NSLog(@"%@", self.currentHost);
        self.processingHost = NO;
    }
    else if (self.processingHost)
    {
        [self setCurrentHostTagValue:elementName withTagData:[self.currentTagData copy]];
    }
    else if ([elementName isEqualToString:SERVICE_TAG_NAME])
    {
        // need to add the service to the correct host.
        NagiosHost *host = [self.hostCollection objectForKey:self.currentHostService.hostname];
        
        if (host)
            [host.services addObject:self.currentHostService];
        self.processingService = NO;
    }
    else if (self.processingService)
    {
        [self setCurrentServiceTagValue:elementName withTagData:[self.currentTagData copy]];
    }
}

// read the data between the tags
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    //NSLog(@"string=%@", string);
    [self.currentTagData appendString:string]; // buffer the data that appears between the tags    
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    NSString *s = [NSString stringWithFormat:@"Error %i, Description: %@, Line: %i, Column: %i", [parseError code],
     [[parser parserError] localizedDescription], [parser lineNumber],
     [parser columnNumber]];
    NSLog(@"%@", s);    
}

@end
