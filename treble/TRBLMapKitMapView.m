//
//  TRBLMapKitMapView.m
//  treble
//
//  Created by Jason Wray on 4/30/15.
//  Copyright (c) 2015 Mapbox. All rights reserved.
//

#import "TRBLMapKitMapView.h"
#import "TRBLCoordinator.h"

#import "Constants.h"

#import <MapKit/MapKit.h>
#import "Additions/MKMapView+Bounds.h"

@interface TRBLMapKitMapView () <MKMapViewDelegate, TRBLCoordinatorDelegate>

@property (nonatomic) IBOutlet MKMapView *mapView;
@property TRBLCoordinator *coordinator;
@property (nonatomic) BOOL shouldUpdateCoordinates;

@end

@implementation TRBLMapKitMapView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.coordinator = [TRBLCoordinator sharedCoordinator];
    
    self.mapView.showsUserLocation = YES;
    self.mapView.delegate = self;
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
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    self.shouldUpdateCoordinates = YES;
}

- (void)mapShouldChangeStyle {
    [self cycleStyles];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)cycleStyles {
    MKMapType mapType;

    if (!self.mapView.showsTraffic &&
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

/*
- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView {
    NSLog(@"start LOADING");
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView {
    NSLog(@"finish LOADING");
}

-(void)mapViewWillStartRenderingMap:(MKMapView *)mapView {
    NSLog(@"start RENDERING");
}

- (void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered {
    NSLog(@"finish RENDERING fullyRendered: %@", fullyRendered ? @"YES":@"NO");
}
*/

@end
