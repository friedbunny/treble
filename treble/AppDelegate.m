//
//  AppDelegate.m
//  treble
//
//  Created by Jason Wray on 4/30/15.
//  Copyright (c) 2015 Mapbox. All rights reserved.
//

#import "AppDelegate.h"

@import Crashlytics;
@import Mapbox;
#import <GoogleMaps/GMSServices.h>

#import "Constants.h"
#import "Additions/UITabBarController+Swipe.h"
#import "Additions/UITabBarController+Index.h"
#import "TRBLMapboxMapView.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // set global app tint color to Mapbox turquoise
    self.window.tintColor = [UIColor colorWithRed:59.f/255.f green:178.f/255.f blue:208.f/255.f alpha:1.f];
    [[UIView appearanceWhenContainedInInstancesOfClasses:@[[UIAlertController class]]] setTintColor:self.window.tintColor];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults registerDefaults:@{
        @"TRBLUIAlwaysShowMapInfoLabel": @YES,
        @"TRBLDebugOptionsTileBoundaries": @NO,
        @"TRBLDebugOptionsTileInfo": @NO,
        @"TRBLDebugOptionsTileTimestamps": @NO,
        @"TRBLDebugOptionsCollisionBoxes": @NO,
    }];

    // API key initialization
    //
    // read APIKeys.plist, see APIKeys.EXAMPLE.plist for the format
    NSDictionary *apiKeys = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"APIKeys" ofType:@"plist"]];

    // Crashlytics API key
    NSString *crashlyticsAPIKey = [apiKeys objectForKey:@"Crashlytics API Key"];
    NSAssert(crashlyticsAPIKey, @"REQUIRED: Crashlytics API key must be set in APIKeys.plist");
    [Crashlytics startWithAPIKey:crashlyticsAPIKey];
    [self setupCrashlytics];

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
    tabBarController.selectedIndex = tabBarController.lastSelectedIndex = TRBLMapboxViewControllerIndex;

    // setup swipe transitions for tab bar
    [tabBarController setupSwipeGestureRecognizersAllowCyclingThroughTabs:YES];

    return YES;
}

#pragma mark - URL schemes

- (BOOL)application:(UIApplication *)application openURL:(nonnull NSURL *)url options:(nonnull NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    if ([url.scheme isEqualToString:TRBLURLScheme]) {
        UITabBarController *tabBarController = (UITabBarController *)application.keyWindow.rootViewController;
        TRBLMapboxMapView *mapboxViewController = tabBarController.viewControllers[TRBLMapboxViewControllerIndex];
        return [mapboxViewController loadMapFromURLScheme:url];
    }

    return NO;
}

#pragma mark - Status bar touch tracking

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    CGPoint location = [[[event allTouches] anyObject] locationInView:[self window]];
    CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
    if (CGRectContainsPoint(statusBarFrame, location)) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kStatusBarTappedNotification object:nil];
    }
}

#pragma mark - Crashlytics

- (void)setupCrashlytics {
    [[Crashlytics sharedInstance] setUserName:UIDevice.currentDevice.name];
    [[Crashlytics sharedInstance] setUserIdentifier:UIDevice.currentDevice.identifierForVendor.UUIDString];
}

@end
