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
#import "UIColor+Treble.h"
#import "TRBLTabBarController.h"
#import "TRBLMapboxMapView.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Set global app tint color
    self.window.tintColor = UIColor.trbl_tintColor;
    [[UIView appearanceWhenContainedInInstancesOfClasses:@[[UIAlertController class]]] setTintColor:self.window.tintColor];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults registerDefaults:@{
        TRBLDefaultsUIAlwaysShowMapInfoLabel: @YES,
        TRBLDefaultsMapboxLocalizesStyle: @YES,
        TRBLDefaultsDebugOptionsTileBoundaries: @NO,
        TRBLDefaultsDebugOptionsTileInfo: @NO,
        TRBLDefaultsDebugOptionsTileTimestamps: @NO,
        TRBLDefaultsDebugOptionsCollisionBoxes: @NO,
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
    [defaults setBool:NO forKey:@"MGLMapboxMetricsEnabled"];

    // Google Maps iOS SDK key
    NSString *googleAPIKey = [apiKeys objectForKey:@"Google Maps iOS API Key"];
    NSAssert(googleAPIKey, @"REQUIRED: Google Maps iOS API key must be set in APIKeys.plist");
    [GMSServices provideAPIKey:googleAPIKey];

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

#pragma mark - URL schemes

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler {
    completionHandler([self handleShortcut:shortcutItem]);
}

- (BOOL)handleShortcut:(UIApplicationShortcutItem *)shortcut {
    if ([[shortcut.type componentsSeparatedByString:@"."].lastObject isEqual:@"settings"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        });

        return YES;
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
    [Crashlytics.sharedInstance setUserName:UIDevice.currentDevice.name];

    NSBundle *mapboxFrameworkBundle = [NSBundle bundleForClass:MGLMapView.class];
    NSString *mapboxSDKVersion = [mapboxFrameworkBundle objectForInfoDictionaryKey:@"MGLSemanticVersionString"] ?: @"unknown";
    NSString *mapboxSDKCommitHash = [mapboxFrameworkBundle objectForInfoDictionaryKey:@"MGLCommitHash"] ?: @"unknown";
    [Crashlytics.sharedInstance setObjectValue:mapboxSDKVersion forKey:@"mapbox.sdkVersion"];
    [Crashlytics.sharedInstance setObjectValue:mapboxSDKCommitHash forKey:@"mapbox.sdkCommitHash"];
}

@end
