//
//  MKMapView+Bounds.m
//  Treble
//
//  Based on: http://stackoverflow.com/a/23808369/2094275
//
//  Created by Jason Wray on 5/4/15.
//  Copyright (c) 2015 Mapbox. All rights reserved.
//

#import "MKMapView+Bounds.h"

@implementation MKMapView (Bounds)

- (void)fitBoundsToSouthWestCoordinate:(CLLocationCoordinate2D)southWestCoordinate northEastCoordinate:(CLLocationCoordinate2D)northEastCoordinate
{

    CLLocationDegrees latitudeDelta = northEastCoordinate.latitude - southWestCoordinate.latitude;
    
    CLLocationCoordinate2D centre;
    CLLocationDegrees longitudeDelta;
    
    if (northEastCoordinate.longitude >= southWestCoordinate.longitude) {
        // Standard case
        centre = CLLocationCoordinate2DMake(
                                            (southWestCoordinate.latitude + northEastCoordinate.latitude) / 2,
                                            (southWestCoordinate.longitude + northEastCoordinate.longitude) / 2);
        longitudeDelta = northEastCoordinate.longitude - southWestCoordinate.longitude;
    } else {
        // Region spans the international dateline
        centre = CLLocationCoordinate2DMake(
                                            (southWestCoordinate.latitude + northEastCoordinate.latitude) / 2,
                                            (southWestCoordinate.longitude + northEastCoordinate.longitude + 360) / 2);
        longitudeDelta = northEastCoordinate.longitude + 360 - southWestCoordinate.longitude;
    }
    
    MKCoordinateSpan span = MKCoordinateSpanMake(latitudeDelta, longitudeDelta);
    MKCoordinateRegion region = MKCoordinateRegionMake(centre, span);
    
    self.region = region;
}

- (CLLocationCoordinate2D)southWestCoordinate
{
    MKCoordinateRegion region = self.region;
    
    double min_lat = region.center.latitude - region.span.latitudeDelta / 2;
    double min_lon = region.center.longitude - region.span.longitudeDelta / 2;
    
    return CLLocationCoordinate2DMake(min_lat, min_lon);
}

- (CLLocationCoordinate2D)northEastCoordinate
{
    MKCoordinateRegion region = self.region;
    
    double max_lat = region.center.latitude + region.span.latitudeDelta / 2;
    double max_lon = region.center.longitude + region.span.longitudeDelta / 2;
    
    return CLLocationCoordinate2DMake(max_lat, max_lon);
}

/*- (NSUInteger)zoomLevel {
 return log2(360 * ((self.frame.size.width/256) / self.region.span.longitudeDelta)) + 1;
}*/

@end
