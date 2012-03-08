//
//  NagiosHostService.m
//  MobileNagios
//
//  Created by Jason Myerscough on 05/03/2012.
//  Copyright (c) 2012 Jason Myerscough. All rights reserved.
//

#import "NagiosHostService.h"

@implementation NagiosHostService

@synthesize hostname = _hostname;
@synthesize serviceDescription = _serviceDescription;
@synthesize modifiedAttributes = _modifiedAttributes;
@synthesize checkCommand = _checkCommand;
@synthesize checkPeriod = _checkPeriod;
@synthesize notificationPeriod = _notificationPeriod;
@synthesize checkInterval = _checkInterval;
@synthesize retryInterval = _retryInterval;
@synthesize eventHandler = _eventHandler;
@synthesize hasBeenChecked = _hasBeenChecked;
@synthesize shouldBeScheduled = _shouldBeScheduled;
@synthesize checkExecutionTime = _checkExecutionTime;
@synthesize checkLatency = _checkLatency;
@synthesize checkType = _checkType;
@synthesize currentState = _currentState;
@synthesize lastHardState = _lastHardState;
@synthesize lastEventId = _lastEventId;
@synthesize currentEventId = _currentEventId;
@synthesize currentProblemId = _currentProblemId;
@synthesize lastProblemId = _lastProblemId;
@synthesize currentAttempt = _currentAttempt;
@synthesize maxAttempts = _maxAttempts;
@synthesize stateType = _stateType;
@synthesize lastStateChange = _lastStateChange;
@synthesize lastHardStateChange = _lastHardStateChange;
@synthesize lastTimeOk = _lastTimeOk;
@synthesize lastTimeWarning = _lastTimeWarning;
@synthesize lastTimeUnknown = _lastTimeUnknown;
@synthesize lastTimeCritical = _lastTimeCritical;
@synthesize pluginOutput = _pluginOutput;
@synthesize longPluginOutput = _longPluginOutput;
@synthesize performanceData = _performanceData;
@synthesize lastCheck = _lastCheck;
@synthesize nextCheck = _nextCheck;
@synthesize checkOptions = _checkOptions;
@synthesize currentNotificationNumber = _currentNotificationNumber;
@synthesize currentNotificationId = _currentNotificationId;
@synthesize lastNotification = _lastNotification;
@synthesize nextNotification = _nextNotification;
@synthesize noMoreNotifications = _noMoreNotifications;
@synthesize notificationsEnabled = _notificationsEnabled;
@synthesize activeChecksEnabled = _activeChecksEnabled;
@synthesize passiveChecksEnabled = _passiveChecksEnabled;
@synthesize eventHandlerEnabled = _eventHandlerEnabled;
@synthesize problemHasBeenAcknowledged = _problemHasBeenAcknowledged;
@synthesize acknowledgementType = _acknowledgementType;
@synthesize flapPredictionEnabled = _flapPredictionEnabled;
@synthesize processPerformanceData = _processPerformanceData;
@synthesize obsessOverService = _obsessOverService;
@synthesize lastUpdate = _lastUpdate;
@synthesize isFlapping = _isFlapping;
@synthesize percentStateChange = _percentStateChange;
@synthesize scheduledDowntimeDepth = _scheduledDowntimeDepth;
@synthesize failurePredictionEnabled = _failurePredictionEnabled;


@end
