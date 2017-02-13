//
//  TRBLMapKitMapView.m
//  treble
//
//  Created by Jason Wray on 4/30/15.
//  Copyright (c) 2015 Mapbox. All rights reserved.
//

#import "TRBLMapKitMapView.h"
#import "TRBLCoordinator.h"
#import "TRBLZoomLabelView.h"

#import "Constants.h"
#import "UITabBarController+Visible.h"

#import <MapKit/MapKit.h>
#import "Additions/MKMapView+Bounds.h"

@interface TRBLMapKitMapView () <MKMapViewDelegate, TRBLCoordinatorDelegate>

@property (nonatomic) IBOutlet MKMapView *mapView;
@property TRBLCoordinator *coordinator;
@property (nonatomic) BOOL shouldUpdateCoordinates;
@property (nonatomic) IBOutlet TRBLZoomLabelView *zoomLabelView;

@end

@implementation TRBLMapKitMapView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.coordinator = [TRBLCoordinator sharedCoordinator];
    
    self.mapView.showsUserLocation = YES;
    self.mapView.delegate = self;

    // Add tab bar controller toggle gesture
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:nil];
    doubleTap.numberOfTapsRequired = 2;
    [self.mapView addGestureRecognizer:doubleTap];

    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleTabBarController:)];
    [singleTap requireGestureRecognizerToFail:doubleTap];
    [self.mapView addGestureRecognizer:singleTap];

//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(defaultsChanged:) name:NSUserDefaultsDidChangeNotification object:nil];
//    [self defaultsChanged:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.coordinator.delegate = self;
    
    //NSLog(@"APPL appear: %f,%f by %f,%f", self.coordinator.southWest.latitude, self.coordinator.southWest.longitude, self.coordinator.northEast.latitude, self.coordinator.northEast.longitude);
    
    if (self.coordinator.needsUpdateMapKit) {
        //NSLog(@"APPL: Updating start coords");
        [self.mapView fitBoundsToSouthWestCoordinate:self.coordinator.southWest northEastCoordinate:self.coordinator.northEast];
        self.mapView.camera.heading = self.coordinator.bearing;
        self.coordinator.needsUpdateMapKit = NO;
    }

    //[self updateZoomLabel];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarTappedAction:) name:kStatusBarTappedNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.shouldUpdateCoordinates) {
        self.coordinator.southWest = self.mapView.southWestCoordinate;
        self.coordinator.northEast = self.mapView.northEastCoordinate;
        self.coordinator.centerCoordinate = self.mapView.centerCoordinate;
        self.coordinator.bearing = self.mapView.camera.heading;
        
        [self.coordinator setNeedsUpdateFromVendor:TRBLMapVendorMapKit];
        self.shouldUpdateCoordinates = NO;
    }
    
    //NSLog(@"APPL disappear: %f,%f by %f,%f", self.coordinator.southWest.latitude, self.coordinator.southWest.longitude, self.coordinator.northEast.latitude, self.coordinator.northEast.longitude);
    
    self.coordinator.delegate = nil;

    [[NSNotificationCenter defaultCenter] removeObserver:self name:kStatusBarTappedNotification object:nil];

    //[self resetZoomLabel];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    self.shouldUpdateCoordinates = YES;
    //[self updateZoomLabel];
}

//- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
//    [self updateZoomLabel];
//}
//
//- (void)updateZoomLabel {
//    self.zoomLabelView.zoomLevel = self.mapView.zoomLevel;
//}
//
//- (void)resetZoomLabel {
//    self.zoomLabelView.zoomLevel = 0;
//}

- (void)mapShouldChangeStyle {
    [self cycleStyles];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)cycleStyles {
    MKMapType mapType;

    if (!self.mapView.showsTraffic &&
        self.mapView.zoomLevel >= 9.0 &&
        self.mapView.mapType != MKMapTypeSatellite && self.mapView.mapType != MKMapTypeSatelliteFlyover) {
        // If traffic wasn't enabled, stay on the same mapType and enable traffic.
        // Non-hybrid satellite does not support traffic.
        self.mapView.showsTraffic = YES;
    } else {
        switch (self.mapView.mapType) {
            case MKMapTypeStandard:
                mapType = MKMapTypeSatelliteFlyover;
                break;

            case MKMapTypeSatellite:
            case MKMapTypeSatelliteFlyover:
                mapType = MKMapTypeHybridFlyover;
                break;

            case MKMapTypeHybrid:
            case MKMapTypeHybridFlyover:
                mapType = MKMapTypeStandard;
                break;
        }

        self.mapView.mapType = mapType;
        self.mapView.showsTraffic = NO;
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    UIStatusBarStyle style;

    switch (self.mapView.mapType) {
        case MKMapTypeStandard:
            style = UIStatusBarStyleDefault;
            break;

        case MKMapTypeSatellite:
        case MKMapTypeSatelliteFlyover:
        case MKMapTypeHybrid:
        case MKMapTypeHybridFlyover:
            style = UIStatusBarStyleLightContent;
            break;
    }

    return style;
}

- (void)statusBarTappedAction:(NSNotification*)notification {
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
}

- (void)toggleTabBarController:(__unused UITapGestureRecognizer *)gestureRecognizer {
    [UIView animateWithDuration:0.15 animations:^{
        [self.tabBarController toggleTabBar];
        for (UIView *subView in self.mapView.subviews) {
            if ([subView isMemberOfClass:NSClassFromString(@"MKAttributionLabel")]) {
                CGFloat tabBarHeight = self.tabBarController.tabBar.frame.size.height;
                subView.frame = CGRectOffset(subView.frame, 0, (self.tabBarController.tabBarIsVisible ? -tabBarHeight : tabBarHeight));
            }
        }
    }];
}

//- (void)defaultsChanged:(__unused NSNotification *)notification {
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//
//    self.zoomLabelView.hidden = ![defaults boolForKey:@"TRBLUIZoomLevel"];
//}

@end
