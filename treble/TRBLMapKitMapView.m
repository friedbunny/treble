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

@import MapKit;
#import "Additions/MKMapView+ZoomLevel.h"

static const double MAPKIT_ZOOM_OFFSET = 1;

@interface TRBLMapKitMapView () <MKMapViewDelegate, TRBLCoordinatorDelegate, UIGestureRecognizerDelegate>

@property (nonatomic) IBOutlet MKMapView *mapView;
@property TRBLCoordinator *coordinator;
@property (nonatomic) BOOL shouldUpdateCoordinates;
@property (nonatomic) IBOutlet TRBLZoomLabelView *mapInfoView;

@end

@implementation TRBLMapKitMapView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.coordinator = [TRBLCoordinator sharedCoordinator];
    
    self.mapView.showsUserLocation = YES;
    self.mapView.delegate = self;

    [self removeInsets];

    // Add tab bar controller toggle gesture
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:nil];
    doubleTap.numberOfTapsRequired = 2;
    [self.mapView addGestureRecognizer:doubleTap];

    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleTabBarController:)];
    [singleTap requireGestureRecognizerToFail:doubleTap];
    [self.mapView addGestureRecognizer:singleTap];

    // Add simultaneously-recognized pinch gesture to update the debug label.
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(updateMapInfoViewAnimated:)];
    pinch.delegate = self;
    [self.mapView addGestureRecognizer:pinch];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(defaultsChanged:) name:NSUserDefaultsDidChangeNotification object:nil];
    [self defaultsChanged:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.coordinator.delegate = self;

    if (self.coordinator.needsUpdateMapKit) {
        [self.mapView setCenterCoordinate:self.coordinator.centerCoordinate
                                zoomLevel:self.coordinator.zoomLevel + MAPKIT_ZOOM_OFFSET
                                 animated:NO];
        self.mapView.camera.heading = self.coordinator.heading;
        //self.mapView.camera.pitch = self.coordinator.pitch;
        self.coordinator.needsUpdateMapKit = NO;
    }

    [self updateMapInfoViewAnimated:NO];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarTappedAction:) name:kStatusBarTappedNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.shouldUpdateCoordinates) {
        self.coordinator.centerCoordinate = self.mapView.centerCoordinate;
        self.coordinator.heading = self.mapView.camera.heading;
        self.coordinator.zoomLevel = self.mapView.zoomLevel - MAPKIT_ZOOM_OFFSET;
        //self.coordinator.pitch = self.mapView.camera.pitch;
        
        [self.coordinator setNeedsUpdateFromVendor:TRBLMapVendorMapKit];
        self.shouldUpdateCoordinates = NO;
    }
    
    self.coordinator.delegate = nil;

    [[NSNotificationCenter defaultCenter] removeObserver:self name:kStatusBarTappedNotification object:nil];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    self.shouldUpdateCoordinates = YES;
    [self updateMapInfoViewAnimated:YES];
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    [self updateMapInfoViewAnimated:YES];
}

- (void)updateMapInfoViewAnimated:(BOOL)animated {
    if (!animated) {
        self.mapInfoView.alpha = 1;
    }
    self.mapInfoView.zoomLevel = self.mapView.zoomLevel;
    self.mapInfoView.pitch = self.mapView.camera.pitch;
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
    [self.tabBarController toggleTabBarAnimated:YES];
}

/** Insets (margins) cause the center coordinate to be offset — for now, remove them. */
- (void)removeInsets {
    CGFloat statusBarInset = UIApplication.sharedApplication.statusBarHidden ? 0 : UIApplication.sharedApplication.statusBarFrame.size.height;
    self.mapView.layoutMargins = UIEdgeInsetsMake(-statusBarInset, 0, -self.tabBarController.tabBar.frame.size.height, 0);
}

/** Update insets when the view changes size (mainly due to rotation). */
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        // no-op
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self removeInsets];
    }];
}

- (void)defaultsChanged:(__unused NSNotification *)notification {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.mapInfoView.hidden = ![defaults boolForKey:@"TRBLUIZoomLevel"];
}

#pragma mark - TRBLCoordinatorDelegate

- (void)mapShouldChangeStyle {
    [self cycleStyles];
    [self setNeedsStatusBarAppearanceUpdate];
}

#pragma mark - UIGestureRecognizerDelegate

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end
