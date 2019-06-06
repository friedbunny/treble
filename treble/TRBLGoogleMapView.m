//
//  TRBLGoogleMapView.m
//  Treble
//
//  Created by Jason Wray on 4/30/15.
//  Copyright (c) 2015 Mapbox. All rights reserved.
//

#import "TRBLGoogleMapView.h"
#import "TRBLCoordinator.h"
#import "TRBLZoomLabelView.h"

#import "Constants.h"
#import "UITabBarController+Visible.h"

@import GoogleMaps;

static const double GOOGLE_ZOOM_OFFSET = 1;

@interface TRBLGoogleMapView () <GMSMapViewDelegate, TRBLCoordinatorDelegate>

@property (nonatomic) IBOutlet GMSMapView *mapView;
@property TRBLCoordinator *coordinator;
@property (nonatomic) BOOL shouldUpdateCoordinates;
@property (nonatomic) IBOutlet TRBLZoomLabelView *mapInfoView;

@end

@implementation TRBLGoogleMapView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.coordinator = [TRBLCoordinator sharedCoordinator];

    self.mapView.myLocationEnabled = YES;
    self.mapView.settings.compassButton = YES;
    self.mapView.paddingAdjustmentBehavior = kGMSMapViewPaddingAdjustmentBehaviorNever;
    self.mapView.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.coordinator.delegate = self;
    self.coordinator.activeVendor = @"google";

    if (self.coordinator.needsUpdateGoogle) {
        GMSCameraPosition *p = [GMSCameraPosition cameraWithLatitude:self.coordinator.centerCoordinate.latitude
                                                           longitude:self.coordinator.centerCoordinate.longitude
                                                                zoom:(float)self.coordinator.zoomLevel + GOOGLE_ZOOM_OFFSET
                                                             bearing:self.coordinator.heading
                                                        viewingAngle:self.coordinator.pitch];
        GMSCameraUpdate *cameraUpdate = [GMSCameraUpdate setCamera:p];
        [self.mapView moveCamera:cameraUpdate];
        
        self.coordinator.needsUpdateGoogle = NO;
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarTappedAction:) name:kStatusBarTappedNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.shouldUpdateCoordinates) {
        self.coordinator.centerCoordinate = self.mapView.camera.target;
        self.coordinator.heading = self.mapView.camera.bearing;
        self.coordinator.zoomLevel = (double)self.mapView.camera.zoom - GOOGLE_ZOOM_OFFSET;
        self.coordinator.pitch = (CGFloat)self.mapView.camera.viewingAngle;
        
        [self.coordinator setNeedsUpdateFromVendor:TRBLMapVendorGoogle];
        self.shouldUpdateCoordinates = NO;
    }
    
    self.coordinator.delegate = nil;

    [[NSNotificationCenter defaultCenter] removeObserver:self name:kStatusBarTappedNotification object:nil];
}

- (void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position {
    self.shouldUpdateCoordinates = YES;
    [self updateMapInfoViewAnimated:YES];
}

- (void)updateMapInfoViewAnimated:(BOOL)animated {
    if (!animated) {
        self.mapInfoView.alpha = 1;
    }
    self.mapInfoView.zoomLevel = self.mapView.camera.zoom;
    self.mapInfoView.pitch = (CGFloat)self.mapView.camera.viewingAngle;
}

- (void)mapShouldChangeStyle {
    [self cycleStyles];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)cycleStyles {
    GMSMapViewType mapType;

    if (!self.mapView.trafficEnabled && self.mapView.camera.zoom >= 4.75) {
        // If traffic wasn't enabled, stay on the same mapType and enable traffic.
        self.mapView.trafficEnabled = YES;
    } else {
        switch (self.mapView.mapType) {
            case kGMSTypeNormal:
                mapType = (self.mapView.camera.zoom > 15.f) ? kGMSTypeSatellite : kGMSTypeTerrain;
                break;

            case kGMSTypeTerrain:
                mapType = kGMSTypeSatellite;
                break;

            case kGMSTypeSatellite:
                mapType = kGMSTypeHybrid;
                break;

            case kGMSTypeHybrid:
            case kGMSTypeNone:
                mapType = kGMSTypeNormal;
                break;
        }

        self.mapView.mapType = mapType;
        self.mapView.trafficEnabled = NO;
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    UIStatusBarStyle style;

    switch (self.mapView.mapType) {
        case kGMSTypeNormal:
        case kGMSTypeTerrain:
        default:
            style = UIStatusBarStyleDefault;
            break;

        case kGMSTypeSatellite:
        case kGMSTypeHybrid:
        case kGMSTypeNone:
            style = UIStatusBarStyleLightContent;
            break;
    }

    return style;
}

- (void)statusBarTappedAction:(NSNotification*)notification {
    [self moveCameraToUserLocation];
}

- (void)mapView:(GMSMapView *)mapView didTapMyLocation:(CLLocationCoordinate2D)location {
    [self moveCameraToUserLocation];
}

- (void)moveCameraToUserLocation {
    if (!self.mapView.myLocation) return;

    if (CLLocationCoordinate2DIsValid(self.mapView.myLocation.coordinate)) {
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithTarget:self.mapView.myLocation.coordinate zoom:self.mapView.camera.zoom];
        [self.mapView animateToCameraPosition:camera];
    }
}

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    [self.tabBarController toggleTabBarAnimated:YES];
}

@end
