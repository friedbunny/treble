//
//  MKMapView+ZoomLevel.h
//  Treble
//
//  Created by Jason Wray on 4/11/17.
//  Copyright (c) 2017 Mapbox. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKMapView (ZoomLevel)

- (double)zoomLevel;
- (MKZoomScale)zoomScale;

- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate zoomLevel:(double)zoomLevel animated:(BOOL)animated;

@end
