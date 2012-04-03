//
//  NagiosHost.h
//  MobileNagios
//
//  Created by Jason Myerscough on 05/03/2012.
//  Copyright (c) 2012 Jason Myerscough. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NagiosHostService.h"

// Used to store the contents of a host entity.
@interface NagiosHost : NSObject

typedef enum NagiosHostState_t
{
    NagiosHostPending     = 1,  // need to resolve this value
    NagiosHostUp          = 0,
    NagiosHostDown        = 1,
    NagiosHostUnreachable = 8   // need to resolve this value
} NagiosHostState;

@property (nonatomic, strong) NSString *hostName;
@property (nonatomic) NSInteger modifiedAttributes;
@property (nonatomic, strong) NSString * checkCommand;
@property (nonatomic, strong) NSString * checkPeriod;
@property (nonatomic, strong) NSString * notificationPeriod;
@property (nonatomic) float checkInterval;
@property (nonatomic) float retryInterval;
@property (nonatomic, strong) NSString * eventHandler;
@property (nonatomic) BOOL hasBeenChecked;
@property (nonatomic) BOOL shouldBeScheduled;
@property (nonatomic) float checkExecutionTime;
@property (nonatomic) float checkLatency;
@property (nonatomic) NSInteger checkType;
@property (nonatomic) NagiosHostState currentState;
@property (nonatomic) NSInteger lastHardState;
@property (nonatomic) NSInteger lastEventId;
@property (nonatomic) NSInteger currentEventId;
@property (nonatomic) NSInteger currentProblemId;
@property (nonatomic) NSInteger lastProblemId;
@property (nonatomic, strong) NSString *pluginOutput;
@property (nonatomic, strong) NSString *longPluginOutput;
@property (nonatomic, strong) NSString *performanceData;
@property (nonatomic) long lastCheck;
@property (nonatomic) long nextCheck;
@property (nonatomic) NSInteger checkOptions;
@property (nonatomic) NSInteger currentAttempt;
@property (nonatomic) NSInteger maxAttempts;
@property (nonatomic) NSInteger stateType;
@property (nonatomic) long lastStateChange;
@property (nonatomic) long lastHardStateChange;
@property (nonatomic) long lastTimeUp;
@property (nonatomic) long lastTimeDown;
@property (nonatomic) long lastTimeUnreachable;
@property (nonatomic) long lastNotification;
@property (nonatomic) long nextNotification;
@property (nonatomic) BOOL noMoreNotifications;
@property (nonatomic) NSInteger currentNotificationNumber;
@property (nonatomic) NSInteger currentNotificationId;
@property (nonatomic) BOOL notificationsEnabled;
@property (nonatomic) BOOL problemHasBeenAcknowledged;
@property (nonatomic) NSInteger acknowledgementType;
@property (nonatomic) BOOL activeChecksEnabled;
@property (nonatomic) BOOL passiveChecksEnabled;
@property (nonatomic) BOOL eventHandlerEnabled;
@property (nonatomic) BOOL flapDetectionEnabled;
@property (nonatomic) BOOL failurePredictionEnabled;
@property (nonatomic) NSInteger processPerformanceData;
@property (nonatomic) BOOL obsessOverHost;
@property (nonatomic) long lastUpdate;
@property (nonatomic) BOOL isFlapping;
@property (nonatomic) float percentStateChange;
@property (nonatomic) NSInteger scheduledDowntimeDepth;

@property (nonatomic, strong) NSMutableArray *services;

@end

