//
//  TRBLGoogleMapView.m
//  Treble
//
//  Created by Jason Wray on 4/30/15.
//  Copyright (c) 2015 Mapbox. All rights reserved.
//

#import "TRBLGoogleMapView.h"
#import "TRBLCoordinator.h"

#import "Constants.h"

#import <GoogleMaps/GoogleMaps.h>

@interface TRBLGoogleMapView () <GMSMapViewDelegate, TRBLCoordinatorDelegate>

@property (nonatomic) IBOutlet GMSMapView *mapView;
@property TRBLCoordinator *coordinator;
@property (nonatomic) BOOL shouldUpdateCoordinates;

@end

@implementation TRBLGoogleMapView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.coordinator = [TRBLCoordinator sharedCoordinator];

    self.mapView.myLocationEnabled = YES;
    self.mapView.settings.compassButton = YES;
    self.mapView.delegate = self;

    // push attribution and visible region below top status bar, above bottom tab bar
    self.mapView.padding = UIEdgeInsetsMake(12.f, 0, 45.f, 0);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.coordinator.delegate = self;
    
    //NSLog(@"GOOG appear: %f,%f by %f,%f", self.coordinator.southWest.latitude, self.coordinator.southWest.longitude, self.coordinator.northEast.latitude, self.coordinator.northEast.longitude);
    
    if (self.coordinator.needsUpdateGoogle) {
        //NSLog(@"GOOG: Updating start coords");
        
        GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:self.coordinator.southWest coordinate:self.coordinator.northEast];
        GMSCameraUpdate *cameraUpdate = [GMSCameraUpdate fitBounds:bounds withPadding:0];
        [self.mapView moveCamera:cameraUpdate];
        
        if (self.coordinator.bearing != self.mapView.camera.bearing) {
            GMSCameraPosition *position = [GMSCameraPosition cameraWithLatitude:self.mapView.camera.target.latitude
                                                                       longitude:self.mapView.camera.target.longitude zoom:self.mapView.camera.zoom
                                                                         bearing:self.coordinator.bearing
                                                                    viewingAngle:0];
            GMSCameraUpdate *update = [GMSCameraUpdate setCamera:position];
            [self.mapView moveCamera:update];
        }
        
        self.coordinator.needsUpdateGoogle = NO;
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarTappedAction:) name:kStatusBarTappedNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.shouldUpdateCoordinates) {
        self.coordinator.centerCoordinate = self.mapView.camera.target;
        self.coordinator.bearing = self.mapView.camera.bearing;
        
        GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithRegion:self.mapView.projection.visibleRegion];
        self.coordinator.southWest = bounds.southWest;
        self.coordinator.northEast = bounds.northEast;
        
        [self.coordinator setNeedsUpdateFromVendor:TRBLMapVendorGoogle];
        self.shouldUpdateCoordinates = NO;
    }
    
    //NSLog(@"GOOG disappear: %f,%f by %f,%f", self.coordinator.southWest.latitude, self.coordinator.southWest.longitude, self.coordinator.northEast.latitude, self.coordinator.northEast.longitude);
    
    self.coordinator.delegate = nil;

    [[NSNotificationCenter defaultCenter] removeObserver:self name:kStatusBarTappedNotification object:nil];
}

- (void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position {
    self.shouldUpdateCoordinates = YES;
}

- (void)mapShouldChangeStyle {
    [self cycleStyles];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)cycleStyles {
    GMSMapViewType mapType;

    if (!self.mapView.trafficEnabled) {
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
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithTarget:self.mapView.myLocation.coordinate zoom:self.mapView.camera.zoom];
    [self.mapView animateToCameraPosition:camera];
}

@end
