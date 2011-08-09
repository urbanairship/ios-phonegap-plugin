//
//  AppDelegate.m
//  UAPhoneGap
//
//  Created by Jeff Towle on 7/29/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "AppDelegate.h"
#ifdef PHONEGAP_FRAMEWORK
	#import <PhoneGap/PhoneGapViewController.h>
#else
	#import "PhoneGapViewController.h"
#endif

#import "PushNotification.h"

#define UA_HOST @"https://go.urbanairship.com/"
#define UA_KEY @"Your App Key"
#define UA_SECRET @"Your App Secret"

@implementation AppDelegate

@synthesize invokeString;
@synthesize launchNotification;

- (id) init
{	
	/** If you need to do any extra app-specific initialization, you can do it here
	 *  -jm
	 **/
    return [super init];
}

/**
 * This is main kick off after the app inits, the views and Settings are setup here. (preferred - iOS4 and up)
 */
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
// ******** NOTE: removed the following block from the default app delegate as it's assuming
// your app will never receive push notifications
 
//	NSArray *keyArray = [launchOptions allKeys];
//	if ([launchOptions objectForKey:[keyArray objectAtIndex:0]]!=nil) 
//	{
//		NSURL *url = [launchOptions objectForKey:[keyArray objectAtIndex:0]];
//		self.invokeString = [url absoluteString];
//	}
    
    // cache notification, if any, until webview finished loading, then process it if needed
    // assume will not receive another message before webview loaded
    self.launchNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    application.applicationIconBadgeNumber = 0;
    
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

// this happens while we are running ( in the background, or from within our own app )
// only valid if UAPhoneGap.plist specifies a protocol to handle
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url 
{
    // must call super so all plugins will get the notification, and their handlers will be called 
	// super also calls into javascript global function 'handleOpenURL'
    return [super application:application handleOpenURL:url];
}

-(id) getCommandInstance:(NSString*)className
{
	/** You can catch your own commands here, if you wanted to extend the gap: protocol, or add your
	 *  own app specific protocol to it. -jm
	 **/
	return [super getCommandInstance:className];
}

/**
 Called when the webview finishes loading.  This stops the activity view and closes the imageview
 */
- (void)webViewDidFinishLoad:(UIWebView *)theWebView 
{
	// only valid if UAPhoneGap.plist specifies a protocol to handle
	if(self.invokeString)
	{
		// this is passed before the deviceready event is fired, so you can access it in js when you receive deviceready
		NSString* jsString = [NSString stringWithFormat:@"var invokeString = \"%@\";", self.invokeString];
		[theWebView stringByEvaluatingJavaScriptFromString:jsString];
	}
    
    //Now that the web view has loaded, pass on the notfication
    if (launchNotification) {
        PushNotification *pushHandler = [self getCommandInstance:@"PushNotification"];
        
        //NOTE: this drops payloads outside of the "aps" key
        pushHandler.notificationMessage = [launchNotification objectForKey:@"aps"];
    }
    
	return [ super webViewDidFinishLoad:theWebView ];
}

- (void)webViewDidStartLoad:(UIWebView *)theWebView 
{
	return [ super webViewDidStartLoad:theWebView ];
}

/**
 * Fail Loading With Error
 * Error - If the webpage failed to load display an error with the reason.
 */
- (void)webView:(UIWebView *)theWebView didFailLoadWithError:(NSError *)error 
{
	return [ super webView:theWebView didFailLoadWithError:error ];
}

/**
 * Start Loading Request
 * This is where most of the magic happens... We take the request(s) and process the response.
 * From here we can re direct links and other protocalls to different internal methods.
 */
- (BOOL)webView:(UIWebView *)theWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	return [ super webView:theWebView shouldStartLoadWithRequest:request navigationType:navigationType ];
}


- (BOOL) execute:(InvokedUrlCommand*)command
{
	return [super execute:command];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    PushNotification *pushHandler = [self getCommandInstance:@"PushNotification"];
    [pushHandler didRegisterForRemoteNotificationsWithDeviceToken:deviceToken host:UA_HOST appKey:UA_KEY appSecret:UA_SECRET];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    PushNotification *pushHandler = [self getCommandInstance:@"PushNotification"];
    [pushHandler didFailToRegisterForRemoteNotificationsWithError:error];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"didReceiveNotification");
    
    // NOTE this is a 4.x only block -- TODO: add 3.x compatibility
    if (application.applicationState == UIApplicationStateActive) {
        NSLog(@"active");
        PushNotification *pushHandler = [self getCommandInstance:@"PushNotification"];
        pushHandler.notificationMessage = [userInfo objectForKey:@"aps"];
        [pushHandler notificationReceived];
    } else {
        NSLog(@"other");
        self.launchNotification = userInfo;//[userInfo objectForKey:@"aps"];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    NSLog(@"active");

    if (![self.webView isLoading] && self.launchNotification) {
        PushNotification *pushHandler = [self getCommandInstance:@"PushNotification"];
        pushHandler.notificationMessage = [self.launchNotification objectForKey:@"aps"];
        //[pushHandler notificationReceived];
        
        [pushHandler performSelectorOnMainThread:@selector(notificationReceived) withObject:pushHandler waitUntilDone:NO];
    }
    
    [super applicationDidBecomeActive:application];
}

- (void)dealloc
{
    launchNotification = nil;
	[super dealloc];
}

@end
