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
    
    [connection start];
    
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

- (NSArray *)getHosts
{
    NSMutableArray *hostCollection = nil;
    NSEnumerator *enumerator = [self.hostCollection keyEnumerator];
    NSString *currentKey;
    
    while ((currentKey = [enumerator nextObject]))
    {
        if (!hostCollection)
        {
            hostCollection = [[NSMutableArray alloc] init];
        }
        NagiosHost *currentHost = [self.hostCollection objectForKey:currentKey];
        if (currentHost)
            [hostCollection addObject:currentHost];
    }
    return hostCollection;
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
    int currentState = 0;
    
    //NSLog(@"currentId=%d", [currentHostTagId integerValue]);
    
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
            currentState = [self.currentTagData intValue];
            NagiosHostState state = NagiosHostPending;

            switch (currentState)
            {
                case NagiosHostUp:
                    state = NagiosHostUp; break;
                case NagiosHostDown:
                    state = NagiosHostDown; break;
                case NagiosHostUnreachable:
                    state = NagiosHostUnreachable; break;
            }
            self.currentHost.currentState = state;
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
    int currentState = 0;
    
    //NSLog(@"currentId=%d", [currentServiceTagId integerValue]);
    
    switch ([currentServiceTagId integerValue])
    {
        case 0:
            self.currentHostService.hostname = self.currentTagData;
            break;
        case 1:
            self.currentHostService.serviceDescription = self.currentTagData;
            break;
        case 2:
            self.currentHostService.modifiedAttributes = [self.currentTagData integerValue];
            break;
        case 3:
            self.currentHostService.checkCommand = self.currentTagData;
            break;
        case 4:
            self.currentHostService.checkPeriod = self.currentTagData;
            break;
        case 5:
            self.currentHostService.notificationPeriod = self.currentTagData;
            break;
        case 6:
            self.currentHostService.checkInterval = [self.currentTagData floatValue];
            break;
        case 7:
            self.currentHostService.retryInterval = [self.currentTagData floatValue];
            break;
        case 8:
            self.currentHostService.eventHandler = self.currentTagData;
            break;
        case 9:
            self.currentHostService.hasBeenChecked = [self.currentTagData boolValue];
            break;
        case 10:
            self.currentHostService.shouldBeScheduled = [self.currentTagData boolValue];
            break;
        case 11:
            self.currentHostService.checkExecutionTime = [self.currentTagData floatValue];
            break;
        case 12:
            self.currentHostService.checkLatency = [self.currentTagData floatValue];
            break;
        case 13:
            self.currentHostService.checkType = [self.currentTagData integerValue];
            break;
        case 14:
            currentState = [self.currentTagData intValue];
            NagiosServiceState state = NagiosServiceUnknown;
            
            switch (currentState)
            {
            case NagiosServicePending:
                state = NagiosServicePending; break;
            case NagiosServiceOk:
                state = NagiosServiceOk; break;
            case NagiosServiceWarning:
                state = NagiosServiceWarning; break;
                case NagiosServiceCrticial:
                    state = NagiosServiceCrticial;
            }
            self.currentHostService.currentState = state;
            break;
        case 15:
            self.currentHostService.lastHardState = [self.currentTagData integerValue];
            break;
        case 16:
            self.currentHostService.lastEventId = [self.currentTagData integerValue];
            break;
        case 17:
            self.currentHostService.currentEventId = [self.currentTagData integerValue];
            break;
        case 18:
            self.currentHostService.currentProblemId = [self.currentTagData integerValue];
            break;
        case 19:
            self.currentHostService.lastProblemId = [self.currentTagData integerValue];
            break;
        case 20:
            self.currentHostService.currentAttempt = [self.currentTagData integerValue];
            break;
        case 21:
            self.currentHostService.maxAttempts = [self.currentTagData integerValue];
            break;
        case 22:
            self.currentHostService.stateType = [self.currentTagData integerValue];
            break;
        case 23:
            self.currentHostService.lastStateChange = [self.currentTagData longLongValue];
            break;
        case 24:
            self.currentHostService.lastHardStateChange = [self.currentTagData longLongValue];
            break;
        case 25:
            self.currentHostService.lastTimeOk = [self.currentTagData longLongValue];
            break;
        case 26:
            self.currentHostService.lastTimeWarning = [self.currentTagData longLongValue];
            break;
        case 27:
            self.currentHostService.lastTimeUnknown = [self.currentTagData longLongValue];
            break;
        case 28:
            self.currentHostService.lastTimeCritical = [self.currentTagData longLongValue];
            break;
        case 29:
            self.currentHostService.pluginOutput = self.currentTagData;
            break;
        case 30:
            self.currentHostService.longPluginOutput = self.currentTagData;
            break;
        case 31:
            self.currentHostService.performanceData = self.currentTagData;
            break;
        case 32:
            self.currentHostService.lastCheck = [self.currentTagData longLongValue];
            break;
        case 33:
            self.currentHostService.nextCheck = [self.currentTagData longLongValue];
            break;
        case 34:
            self.currentHostService.checkOptions = [self.currentTagData integerValue];
            break;
        case 35:
            self.currentHostService.currentNotificationNumber = [self.currentTagData integerValue];
            break;
        case 36:
            self.currentHostService.currentNotificationId = [self.currentTagData integerValue];
            break;
        case 37:
            self.currentHostService.lastNotification = [self.currentTagData integerValue];
            break;
        case 38:
            self.currentHostService.nextNotification = [self.currentTagData integerValue];
            break;
        case 39:
            self.currentHostService.noMoreNotifications = [self.currentTagData boolValue];
            break;
        case 40:
            self.currentHostService.notificationsEnabled = [self.currentTagData boolValue];
            break;
        case 41:
            self.currentHostService.activeChecksEnabled = [self.currentTagData boolValue];
            break;
        case 42:
            self.currentHostService.passiveChecksEnabled = [self.currentTagData boolValue];
            break;
        case 43:
            self.currentHostService.eventHandlerEnabled = [self.currentTagData boolValue];
            break;
        case 44:
            self.currentHostService.problemHasBeenAcknowledged = [self.currentTagData boolValue];
            break;
        case 45:
            self.currentHostService.acknowledgementType = [self.currentTagData integerValue];
            break;
        case 46:
            self.currentHostService.flapPredictionEnabled = [self.currentTagData boolValue];
            break;
        case 47:
            self.currentHostService.failurePredictionEnabled = [self.currentTagData boolValue];
            break;
        case 48:
            self.currentHostService.processPerformanceData = [self.currentTagData boolValue];
            break;
        case 49:
            self.currentHostService.obsessOverService = [self.currentTagData boolValue];
            break;
        case 50:
            self.currentHostService.lastUpdate = [self.currentTagData longLongValue];
            break;
        case 51:
            self.currentHostService.isFlapping = [self.currentTagData boolValue];
            break;
        case 52:
            self.currentHostService.percentStateChange = [self.currentTagData floatValue];
            break;
        case 53:
            self.currentHostService.scheduledDowntimeDepth = [self.currentTagData integerValue];
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
        self.currentHostService = [[NagiosHostService alloc] init];
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
        {
            NSMutableArray * a = host.services;
            [a addObject:self.currentHostService];
            [self.hostCollection setObject:host forKey:host.hostName]; // update the dictionary
        }
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
