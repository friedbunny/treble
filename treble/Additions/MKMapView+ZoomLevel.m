//
//  MKMapView+ZoomLevel.m
//  Treble
//
//  Based on: http://stackoverflow.com/a/15020534/2094275
//
//  Created by Jason Wray on 4/11/17.
//  Copyright (c) 2017 Mapbox. All rights reserved.
//

#import "MKMapView+ZoomLevel.h"

@implementation MKMapView (ZoomLevel)

- (double)zoomLevel {
    return log2(360 * ((self.frame.size.width/256) / self.region.span.longitudeDelta));
}

- (void)setZoomLevel:(double)zoomLevel {
    [self setCenterCoordinate:self.centerCoordinate zoomLevel:zoomLevel animated:false];
}

// FIXME: ignores pitch.
// FIXME: maxes out at z20 for standard, z15 for flyover.
// FIXME: doesn't handle flyover accurately from z0~z5
- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate zoomLevel:(double)zoomLevel animated:(BOOL)animated {
    MKCoordinateSpan span = MKCoordinateSpanMake(0, 360/pow(2, fabs(zoomLevel)) * self.frame.size.width/256);
    [self setRegion:MKCoordinateRegionMake(centerCoordinate, span) animated:animated];
}

@end
