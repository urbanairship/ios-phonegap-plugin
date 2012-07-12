/*
 Copyright 2009-2011 Urban Airship Inc. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 1. Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2. Redistributions in binaryform must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided withthe distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE URBAN AIRSHIP INC``AS IS'' AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
 EVENT SHALL URBAN AIRSHIP INC OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <Foundation/Foundation.h>
#import <Cordova/CDVPlugin.h>

@interface PushNotification : CDVPlugin {
    
    
    NSString *registerSuccessCallback;
    NSString *registerErrorCallback;
    NSDictionary *notificationMessage;
    
    NSString *notificationCallbackId;
    
    BOOL ready;
}

//pg
@property (nonatomic, copy) NSString *callbackId;
@property (nonatomic, copy) NSString *notificationCallbackId;

@property (nonatomic, retain) NSDictionary *notificationMessage;
@property (nonatomic, retain) NSString *registerSuccessCallback;

- (void)registerAPN:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options;
- (void)startNotify:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options;
- (void)log:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options;


- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
                                                    host:(NSString *)host
                                                  appKey:(NSString *)appKey
                                               appSecret:(NSString *)appSecret;
- (void)didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;

- (void)setNotificationMessage:(NSDictionary *)notification;
- (void)notificationReceived;

@end
