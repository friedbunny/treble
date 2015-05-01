//
//  GMSMapViewExtensions.m
//  http://stackoverflow.com/a/23808369/2094275
//

#import "GMSMapViewExtensions.h"

@implementation GMSMapView (GMSMapViewExtensions)

- (MKCoordinateRegion)region
{
    GMSVisibleRegion visibleRegion = self.projection.visibleRegion;
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithRegion: visibleRegion];
    
    CLLocationDegrees latitudeDelta = bounds.northEast.latitude - bounds.southWest.latitude;
    
    CLLocationCoordinate2D centre;
    CLLocationDegrees longitudeDelta;
    
    if (bounds.northEast.longitude >= bounds.southWest.longitude) {
        // Standard case
        centre = CLLocationCoordinate2DMake(
                                            (bounds.southWest.latitude + bounds.northEast.latitude) / 2,
                                            (bounds.southWest.longitude + bounds.northEast.longitude) / 2);
        longitudeDelta = bounds.northEast.longitude - bounds.southWest.longitude;
    } else {
        // Region spans the international dateline
        centre = CLLocationCoordinate2DMake(
                                            (bounds.southWest.latitude + bounds.northEast.latitude) / 2,
                                            (bounds.southWest.longitude + bounds.northEast.longitude + 360) / 2);
        longitudeDelta = bounds.northEast.longitude + 360 - bounds.southWest.longitude;
    }
    
    MKCoordinateSpan span = MKCoordinateSpanMake(latitudeDelta, longitudeDelta);
    return MKCoordinateRegionMake(centre, span);
}


- (MKMapRect)visibleMapRect
{
    MKCoordinateRegion region = [self region];
    MKMapPoint a = MKMapPointForCoordinate(CLLocationCoordinate2DMake(
                                                                      region.center.latitude + region.span.latitudeDelta / 2,
                                                                      region.center.longitude - region.span.longitudeDelta / 2));
    MKMapPoint b = MKMapPointForCoordinate(CLLocationCoordinate2DMake(
                                                                      region.center.latitude - region.span.latitudeDelta / 2,
                                                                      longitudeDelta / 2));
    return MKMapRectMake(MIN(a.x, b.x), MIN(a.y, b.y), ABS(a.x - b.x), ABS(a.y - b.y));
}

@end