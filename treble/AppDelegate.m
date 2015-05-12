//
//  AppDelegate.m
//  treble
//
//  Created by Jason Wray on 4/30/15.
//  Copyright (c) 2015 Mapbox. All rights reserved.
//

#import "AppDelegate.h"

#import <GoogleMaps/GMSServices.h>
#import <MapboxGL/MapboxGL.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Set global app tint color
    self.window.tintColor = [UIColor colorWithRed:59.f/255.f green:178.f/255.f blue:208.f/255.f alpha:1.f];
    
    // Read APIKeys.plist, see APIKeys.EXAMPLE.plist for the format
    NSDictionary *apiKeys = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"APIKeys" ofType:@"plist"]];
    
    // Mapbox API key
    NSString *mapboxAPIKey = [apiKeys objectForKey:@"Mapbox API Key"];
    NSAssert(mapboxAPIKey, @"REQUIRED: Mapbox API key must be set in APIKeys.plist");
    [MGLAccountManager setAccessToken:mapboxAPIKey];
    
    // Google Maps iOS SDK key
    NSString *googleAPIKey = [apiKeys objectForKey:@"Google Maps iOS API Key"];
    NSAssert(googleAPIKey, @"REQUIRED: Google Maps iOS API key must be set in APIKeys.plist");
    [GMSServices provideAPIKey:googleAPIKey];
    
    // Set initial tab to Mapbox (second, center)
    UITabBarController *tabBar = (UITabBarController *)self.window.rootViewController;
    tabBar.selectedIndex = 1;
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
