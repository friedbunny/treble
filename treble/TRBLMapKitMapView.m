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

@interface TRBLMapKitMapView ()

@property (nonatomic) IBOutlet MKMapView *mapView;
@property TRBLCoordinator *coordinator;

@end

@implementation TRBLMapKitMapView

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.coordinator = [TRBLCoordinator sharedCoordinator];
    
    self.mapView.showsUserLocation = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (CLLocationCoordinate2DIsValid(self.coordinator.region.center))
        self.mapView.region = self.coordinator.region;
    
    else if (CLLocationCoordinate2DIsValid(self.coordinator.currentLocation))
        self.mapView.centerCoordinate = self.coordinator.currentLocation;
    
    TRBLCoordinator *c = [TRBLCoordinator sharedCoordinator];
    NSLog(@"APPLE appear: %f, %f (z%f)", c.currentLocation.latitude, c.currentLocation.longitude, c.currentZoom);
    
    /*MKCoordinateRegion region;
    region.center = [[TRBLCoordinator sharedCoordinator] currentLocation];
    region.span.latitudeDelta = 1;
    region.span.longitudeDelta = 1;
    region = [self.mapView regionThatFits:region];
    [self.mapView setRegion:region animated:NO];*/
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    self.coordinator.currentLocation = self.mapView.centerCoordinate;
    //self.coordinator.currentZoom = 5.f;
    
    TRBLCoordinator *c = [TRBLCoordinator sharedCoordinator];
    NSLog(@"APPLE disappear: %f, %f (z%f)", c.currentLocation.latitude, c.currentLocation.longitude, c.currentZoom);
}

/*- (NSUInteger)zoomLevel {
    return log2(360 * ((self.frame.size.width/256) / self.region.span.longitudeDelta)) + 1;
}*/

@end
