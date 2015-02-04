
//
//  AppDelegate.m
//  Zup
//
//  Created by Renato Kuroe on 23/11/13.
//  Copyright (c) 2013 Renato Kuroe. All rights reserved.
//

#import "AppDelegate.h"
#import "RavenClient.h"
#import <GooglePlus/GooglePlus.h>


@implementation AppDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UITextField* textField = [alertView textFieldAtIndex:0];
    if([textField.text isEqualToString:@"zup_piloto2014"])
    {
        return;
    }
    else
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Senha" message:@"Senha incorreta. Tente novamente." delegate:self cancelButtonTitle:@"Validar" otherButtonTitles: nil];
        alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
        [alert show];
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Senha" message:@"Este aplicativo está em projeto piloto e tem acesso restrito. Para continuar digite a senha que você recebeu para participar desta fase." delegate:self cancelButtonTitle:@"Validar" otherButtonTitles: nil];
    alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
    //[alert show];
    
    NSLog(@"%@", kAPIkey);
    [GMSServices provideAPIKey:kAPIkey];
    
    if ([Utilities isIOS7])
        [[UIApplication sharedApplication]setStatusBarHidden:NO];
    else
        [[UIApplication sharedApplication]setStatusBarHidden:YES];

    [RavenClient clientWithDSN:@"https://866d9108ceed4379aeac03d76b5eb393:15a3c8dae32f474e8cb6ce7199284909@app.getsentry.com/17326"];
    [[RavenClient sharedClient] setupExceptionHandler];
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationType)(UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge)];
    
    return YES;
}

#pragma mark - Token


- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSString* deviceTokenString = [[[[deviceToken description] stringByReplacingOccurrencesOfString: @"<" withString: @""] stringByReplacingOccurrencesOfString: @">" withString: @""] stringByReplacingOccurrencesOfString: @" " withString: @""];
    
    [UserDefaults setDeviceToken:deviceTokenString];
    
    NSLog(@"Token OK: %@", deviceTokenString);
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", [error description]);
}

#pragma mark - Push

- (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    [self processRemoteInfo:userInfo state:application.applicationState];
    
}

- (void)processRemoteInfo:(NSDictionary*)userInfo state:(UIApplicationState)state {
    
    if (state == UIApplicationStateActive) {
    
    } else if (state == UIApplicationStateBackground || state == UIApplicationStateInactive) {
        
    }
    
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application: (UIApplication *)application
            openURL: (NSURL *)url
  sourceApplication: (NSString *)sourceApplication
         annotation: (id)annotation {
    return [GPPURLHandler handleURL:url
                  sourceApplication:sourceApplication
                         annotation:annotation];
}

@end
