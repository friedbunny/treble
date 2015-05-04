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
#import "GMSMapView+Region.h"

@interface TRBLGoogleMapView ()

@property (nonatomic) IBOutlet GMSMapView *mapView;
@property TRBLCoordinator *coordinator;

@end

@implementation TRBLGoogleMapView

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.coordinator = [TRBLCoordinator sharedCoordinator];

    self.mapView.myLocationEnabled = YES;
    self.mapView.settings.compassButton = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    TRBLCoordinator *c = [TRBLCoordinator sharedCoordinator];
    NSLog(@"GOOG appear: %f, %f (z%f)", c.currentLocation.latitude, c.currentLocation.longitude, c.currentZoom);
    
    [self.mapView moveCamera:[GMSCameraUpdate setTarget:self.coordinator.currentLocation
                                                   zoom:self.coordinator.currentZoom]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.coordinator.currentLocation = self.mapView.camera.target;
    self.coordinator.currentZoom = self.mapView.camera.zoom;
    self.coordinator.region = self.mapView.region;
    
    TRBLCoordinator *c = [TRBLCoordinator sharedCoordinator];
    NSLog(@"GOOG disappear: %f, %f (z%f)", c.currentLocation.latitude, c.currentLocation.longitude, c.currentZoom);
}

@end
