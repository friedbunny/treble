//
//  TRBLMapKitMapView.m
//  treble
//
//  Created by Jason Wray on 4/30/15.
//  Copyright (c) 2015 Mapbox. All rights reserved.
//

#import "TRBLMapKitMapView.h"
#import "TRBLCoordinator.h"

#import <MapKit/MapKit.h>
#import "Additions/MKMapView+Bounds.h"

@interface TRBLMapKitMapView () <MKMapViewDelegate>

@property (nonatomic) IBOutlet MKMapView *mapView;
@property TRBLCoordinator *coordinator;
@property (nonatomic) BOOL shouldUpdateCoordinates;

@end

@implementation TRBLMapKitMapView

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.coordinator = [TRBLCoordinator sharedCoordinator];
    
    self.mapView.showsUserLocation = YES;
    self.mapView.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //NSLog(@"APPL appear: %f,%f by %f,%f", self.coordinator.southWest.latitude, self.coordinator.southWest.longitude, self.coordinator.northEast.latitude, self.coordinator.northEast.longitude);
    
    if (self.coordinator.needsUpdateMapKit)
    {
        NSLog(@"APPL: Updating start coords");
        [self.mapView fitBoundsToSouthWestCoordinate:self.coordinator.southWest northEastCoordinate:self.coordinator.northEast];

        self.mapView.camera.heading = self.coordinator.bearing;
        
        self.coordinator.needsUpdateMapKit = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.shouldUpdateCoordinates)
    {
        self.coordinator.southWest = self.mapView.southWestCoordinate;
        self.coordinator.northEast = self.mapView.northEastCoordinate;
        self.coordinator.centerCoordinate = self.mapView.centerCoordinate;
        self.coordinator.bearing = self.mapView.camera.heading;
        
        [self.coordinator setNeedsUpdateFromVendor:TRBLMapVendorMapKit];
        self.shouldUpdateCoordinates = NO;
    }
    
    //NSLog(@"APPL disappear: %f,%f by %f,%f", self.coordinator.southWest.latitude, self.coordinator.southWest.longitude, self.coordinator.northEast.latitude, self.coordinator.northEast.longitude);
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    self.shouldUpdateCoordinates = YES;
}

@end
