//
//  NagiosHostService.h
//  MobileNagios
//
//  Created by Jason Myerscough on 05/03/2012.
//  Copyright (c) 2012 Jason Myerscough. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NagiosHostService : NSObject

typedef enum NagiosServiceState_t
{
    NagiosServicePending  = 1,
    NagiosServiceOk       = 0,
    NagiosServiceWarning  = 4,
    NagiosServiceUnknown  = 8,
    NagiosServiceCrticial = 16
} NagiosServiceState;

@property (nonatomic, strong) NSString *hostname;
@property (nonatomic, strong) NSString *serviceDescription;
@property (nonatomic) NSInteger modifiedAttributes;
@property (nonatomic, strong) NSString *checkCommand;
@property (nonatomic, strong) NSString *checkPeriod;
@property (nonatomic, strong) NSString *notificationPeriod;
@property (nonatomic) float checkInterval;
@property (nonatomic) float retryInterval;
@property (nonatomic, strong) NSString *eventHandler;
@property (nonatomic) BOOL hasBeenChecked;
@property (nonatomic) BOOL shouldBeScheduled;
@property (nonatomic) float checkExecutionTime;
@property (nonatomic) float checkLatency;
@property (nonatomic) NSInteger checkType;
@property (nonatomic) NagiosServiceState currentState;
@property (nonatomic) NSInteger lastHardState;
@property (nonatomic) NSInteger lastEventId;
@property (nonatomic) NSInteger currentEventId;
@property (nonatomic) NSInteger currentProblemId;
@property (nonatomic) NSInteger lastProblemId;
@property (nonatomic) NSInteger currentAttempt;
@property (nonatomic) NSInteger maxAttempts;
@property (nonatomic) NSInteger stateType;
@property (nonatomic) long lastStateChange;
@property (nonatomic) long lastHardStateChange;
@property (nonatomic) long lastTimeOk;
@property (nonatomic) long lastTimeWarning;
@property (nonatomic) long lastTimeUnknown;
@property (nonatomic) long lastTimeCritical;
@property (nonatomic, strong) NSString *pluginOutput;
@property (nonatomic, strong) NSString *longPluginOutput;
@property (nonatomic, strong) NSString *performanceData;
@property (nonatomic) long lastCheck;
@property (nonatomic) long nextCheck;
@property (nonatomic) NSInteger checkOptions;
@property (nonatomic) NSInteger currentNotificationNumber;
@property (nonatomic) NSInteger currentNotificationId;
@property (nonatomic) NSInteger lastNotification;
@property (nonatomic) NSInteger nextNotification;
@property (nonatomic) BOOL noMoreNotifications;
@property (nonatomic) BOOL notificationsEnabled;
@property (nonatomic) BOOL activeChecksEnabled;
@property (nonatomic) BOOL passiveChecksEnabled;
@property (nonatomic) BOOL eventHandlerEnabled;
@property (nonatomic) BOOL problemHasBeenAcknowledged;
@property (nonatomic) NSInteger acknowledgementType;
@property (nonatomic) BOOL flapPredictionEnabled;
@property (nonatomic) BOOL processPerformanceData;
@property (nonatomic) BOOL obsessOverService;
@property (nonatomic) long lastUpdate;
@property (nonatomic) BOOL isFlapping;
@property (nonatomic) float percentStateChange;
@property (nonatomic) NSInteger scheduledDowntimeDepth;
@property (nonatomic) BOOL failurePredictionEnabled;

@end
