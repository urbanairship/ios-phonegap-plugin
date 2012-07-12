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

#import "PushNotification.h"

@implementation PushNotification

@synthesize notificationMessage;
@synthesize registerSuccessCallback;

//pg
@synthesize callbackId;
@synthesize notificationCallbackId;

- (void)dealloc {
    [notificationMessage release];
    [registerSuccessCallback release];

    self.notificationCallbackId = nil;

    [super dealloc];
}

- (void)registerAPN:(NSMutableArray *)arguments
           withDict:(NSMutableDictionary *)options {
    //NSLog(@"registerAPN:%@\n withDict:%@", [arguments description], [options description]);

    self.callbackId = [arguments pop];

    UIRemoteNotificationType notificationTypes = UIRemoteNotificationTypeNone;
    if ([options objectForKey:@"badge"]) {
        notificationTypes |= UIRemoteNotificationTypeBadge;
    }
    if ([options objectForKey:@"sound"]) {
        notificationTypes |= UIRemoteNotificationTypeSound;
    }
    if ([options objectForKey:@"alert"]) {
        notificationTypes |= UIRemoteNotificationTypeAlert;
    }

    if (notificationTypes == UIRemoteNotificationTypeNone)
        NSLog(@"PushNotification.registerAPN: Push notification type is set to none");

    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:notificationTypes];

}

- (void)startNotify:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options {
    NSLog(@"startNotify");

    ready = YES;

    // Check if there is cached notification before JS PushNotification messageCallback is set
    if (notificationMessage) {
        [self notificationReceived];
    }
}

- (void)log:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options {
    NSLog(@"JSLOG: %@", [options valueForKey:@"msg"]);
}

- (void)isEnabled:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options {
    UIRemoteNotificationType type = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
    NSString *jsStatement = [NSString stringWithFormat:@"navigator.pushNotification.isEnabled = %d;", type != UIRemoteNotificationTypeNone];
    NSLog(@"JSStatement %@",jsStatement);
}

- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
                                                    host:(NSString *)host
                                                  appKey:(NSString *)appKey
                                               appSecret:(NSString *)appSecret {
    NSString *token = [[[[deviceToken description] stringByReplacingOccurrencesOfString:@"<"withString:@""]
                        stringByReplacingOccurrencesOfString:@">" withString:@""]
                       stringByReplacingOccurrencesOfString: @" " withString: @""];

    NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken:%@", token);

    NSMutableDictionary *results = [NSMutableDictionary dictionary];
    [results setValue:token forKey:@"deviceToken"];
    [results setValue:host forKey:@"host"];
    [results setValue:appKey forKey:@"appKey"];
    [results setValue:appSecret forKey:@"appSecret"];

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:results];
    [self writeJavascript:[pluginResult toSuccessCallbackString:self.callbackId]];

}

- (void)didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"didFailToRegisterForRemoteNotificationsWithError:%@", error);

    NSMutableDictionary *results = [NSMutableDictionary dictionary];
    [results setValue:[error description] forKey:@"error"];
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:results];
    [self writeJavascript: [pluginResult toErrorCallbackString:self.callbackId]];
}

- (void)notificationReceived {
    NSLog(@"Notification received");
    NSLog(@"Ready: %d",ready);
    NSLog(@"Msg: %@", [notificationMessage descriptionWithLocale:[NSLocale currentLocale] indent:4]);

    if (ready && notificationMessage) {
        NSMutableString *jsonStr = [NSMutableString stringWithString:@"{"];
        if ([notificationMessage objectForKey:@"alert"]) {
            [jsonStr appendFormat:@"alert:'%@',", [[notificationMessage objectForKey:@"alert"]
                                                      stringByReplacingOccurrencesOfString:@"'"
                                                                                withString:@"\\'"]];
        }
        if ([notificationMessage objectForKey:@"badge"]) {
            [jsonStr appendFormat:@"badge:%d,", [[notificationMessage objectForKey:@"badge"] intValue]];
        }
        if ([notificationMessage objectForKey:@"sound"]) {
            [jsonStr appendFormat:@"sound:'%@',", [notificationMessage objectForKey:@"sound"]];
        }
        [jsonStr appendString:@"}"];

        NSString *jsStatement = [NSString stringWithFormat:@"window.plugins.pushNotification.notificationCallback(%@);", jsonStr];
        [self writeJavascript:jsStatement];
        NSLog(@"run JS: %@", jsStatement);

        self.notificationMessage = nil;
    }
}

@end
