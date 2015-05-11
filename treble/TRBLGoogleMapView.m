//
//  TRBLGoogleMapView.m
//  Treble
//
//  Created by Jason Wray on 4/30/15.
//  Copyright (c) 2015 Mapbox. All rights reserved.
//

#import "TRBLGoogleMapView.h"
#import "TRBLCoordinator.h"

#import <GoogleMaps/GoogleMaps.h>

@interface TRBLGoogleMapView () <GMSMapViewDelegate>

@property (nonatomic) IBOutlet GMSMapView *mapView;
@property TRBLCoordinator *coordinator;
@property (nonatomic) BOOL shouldUpdateCoordinates;

@end

@implementation TRBLGoogleMapView

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.coordinator = [TRBLCoordinator sharedCoordinator];

    self.mapView.myLocationEnabled = YES;
    self.mapView.settings.compassButton = YES;
    self.mapView.delegate = self;

    // push attribution and visible region above bottom tab bar, below top status bar
    //self.mapView.padding = UIEdgeInsetsMake(12.f, 0, 45.f, 0);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //NSLog(@"GOOG appear: %f,%f by %f,%f", self.coordinator.southWest.latitude, self.coordinator.southWest.longitude, self.coordinator.northEast.latitude, self.coordinator.northEast.longitude);
    
    if (self.coordinator.needsUpdateGoogle)
    {
        NSLog(@"GOOG: Updating start coords");
        GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:self.coordinator.southWest coordinate:self.coordinator.northEast];
        GMSCameraUpdate *cameraUpdate = [GMSCameraUpdate fitBounds:bounds withPadding:0];
        
        bool animate = NO;
        animate ? [self.mapView animateWithCameraUpdate:cameraUpdate] : [self.mapView moveCamera:cameraUpdate];
        
        self.coordinator.needsUpdateGoogle = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.shouldUpdateCoordinates)
    {
        self.coordinator.centerCoordinate = self.mapView.camera.target;
        self.coordinator.bearing = self.mapView.camera.bearing;
        
        GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithRegion:self.mapView.projection.visibleRegion];
        self.coordinator.southWest = bounds.southWest;
        self.coordinator.northEast = bounds.northEast;
        
        [self.coordinator setNeedsUpdateFromVendor:TRBLMapVendorGoogle];
        self.shouldUpdateCoordinates = NO;
    }
    
    //NSLog(@"GOOG disappear: %f,%f by %f,%f", self.coordinator.southWest.latitude, self.coordinator.southWest.longitude, self.coordinator.northEast.latitude, self.coordinator.northEast.longitude);
}

- (void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position
{
    self.shouldUpdateCoordinates = YES;
}

@end
