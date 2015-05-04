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

@interface TRBLGoogleMapView () <GMSMapViewDelegate>

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
    self.mapView.delegate = self;

    // push attribution and visible region above bottom tab bar, below top status bar
    self.mapView.padding = UIEdgeInsetsMake(12.f, 0, 45.f, 0);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.mapView setRegion:self.coordinator.region bearing:self.coordinator.bearing animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position
{
    self.coordinator.currentLocation = self.mapView.camera.target;
    self.coordinator.currentZoom = self.mapView.camera.zoom;
    self.coordinator.region = self.mapView.region;
    self.coordinator.bearing = self.mapView.camera.bearing;
}

@end
