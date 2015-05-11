//
//  MKMapView+Bounds.h
//  Treble
//
//  Created by Jason Wray on 5/4/15.
//  Copyright (c) 2015 Mapbox. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKMapView (Bounds)

- (void)fitBoundsToSouthWestCoordinate:(CLLocationCoordinate2D)southWestCoordinate northEastCoordinate:(CLLocationCoordinate2D)northEastCoordinate;

- (CLLocationCoordinate2D)southWestCoordinate;
- (CLLocationCoordinate2D)northEastCoordinate;

@end
