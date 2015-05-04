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

@interface TRBLMapKitMapView () <MKMapViewDelegate>

@property (nonatomic) IBOutlet MKMapView *mapView;
@property TRBLCoordinator *coordinator;

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
    
    self.mapView.region = self.coordinator.region;
    self.mapView.camera.heading = self.coordinator.bearing;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    self.coordinator.currentLocation = self.mapView.centerCoordinate;
    self.coordinator.region = self.mapView.region;
    self.coordinator.bearing = self.mapView.camera.heading;
}

/*- (NSUInteger)zoomLevel {
    return log2(360 * ((self.frame.size.width/256) / self.region.span.longitudeDelta)) + 1;
}*/

@end
