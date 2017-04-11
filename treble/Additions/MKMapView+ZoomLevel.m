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

//- (double)zoomLevel {
//    double totalTilesAtMaxZoom = MKMapSizeWorld.width / 256.0;
//    NSInteger zoomLevelAtMaxZoom = log2(totalTilesAtMaxZoom);
//    return MAX(0, zoomLevelAtMaxZoom + log2f(self.zoomScale));
//}

- (MKZoomScale)zoomScale {
   return self.bounds.size.width / self.visibleMapRect.size.width;
}

- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate zoomLevel:(double)zoomLevel animated:(BOOL)animated {
    MKCoordinateSpan span = MKCoordinateSpanMake(0, 360/pow(2, fabs(zoomLevel)) * self.frame.size.width/256);
    [self setRegion:MKCoordinateRegionMake(centerCoordinate, span) animated:animated];
}

@end
