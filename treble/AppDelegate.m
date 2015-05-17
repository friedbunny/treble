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

#import "Additions/UITabBarController+Swipe.h"
#import "Additions/UITabBarController+Index.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // set global app tint color to Mapbox turquoise
    self.window.tintColor = [UIColor colorWithRed:59.f/255.f green:178.f/255.f blue:208.f/255.f alpha:1.f];
    
    // API key initialization
    //
    // read APIKeys.plist, see APIKeys.EXAMPLE.plist for the format
    NSDictionary *apiKeys = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"APIKeys" ofType:@"plist"]];
    
    // Mapbox API key
    NSString *mapboxAPIKey = [apiKeys objectForKey:@"Mapbox API Key"];
    NSAssert(mapboxAPIKey, @"REQUIRED: Mapbox API key must be set in APIKeys.plist");
    [MGLAccountManager setAccessToken:mapboxAPIKey];
    
    // Google Maps iOS SDK key
    NSString *googleAPIKey = [apiKeys objectForKey:@"Google Maps iOS API Key"];
    NSAssert(googleAPIKey, @"REQUIRED: Google Maps iOS API key must be set in APIKeys.plist");
    [GMSServices provideAPIKey:googleAPIKey];
    
    // tab bar customization
    //
    // set initial tab to Mapbox (second, center)
    UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
    tabBarController.selectedIndex = 1;

    // setup swipe transitions for tab bar
    [tabBarController setupSwipeGestureRecognizersAllowCyclingThroughTabs:YES];
    
    return YES;
}

@end
