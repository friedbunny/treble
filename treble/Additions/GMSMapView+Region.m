//
//  GMSMapView+Region.m
//  http://stackoverflow.com/a/23808369/2094275
//

#import "GMSMapView+Region.h"

@implementation GMSMapView (Region)

- (MKCoordinateRegion)region
{
    GMSVisibleRegion visibleRegion = self.projection.visibleRegion;
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithRegion:visibleRegion];
    
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

- (void)setRegion:(MKCoordinateRegion)region animated:(BOOL)animated
{
    // https://bitbucket.org/dlunch/mapchanger/src/beaeb4e5c95df269dd2534ae89cfa757727c2265/GoogleMapView.m?at=master

    double min_lat = region.center.latitude - region.span.latitudeDelta / 2;
    double min_lon = region.center.longitude - region.span.longitudeDelta / 2;
    double max_lat = region.center.latitude + region.span.latitudeDelta / 2;
    double max_lon = region.center.longitude + region.span.longitudeDelta / 2;

    //min of height and width of element which contains the map
    float mapdisplay = MIN(self.frame.size.width, self.frame.size.height);

    const double kRadiusOfEarthInKM = 6378.137;
    const double RAD2DEG = 180.0 / M_PI;

    double dist = (kRadiusOfEarthInKM * acos(sin(min_lat / RAD2DEG) * sin(max_lat / RAD2DEG) + (cos(min_lat / RAD2DEG) * cos(max_lat / RAD2DEG) * cos((max_lon / RAD2DEG) - (min_lon / RAD2DEG)))));

    double zoom = floor(8 - log(1.6446 * dist / sqrt(2 * (mapdisplay * mapdisplay))) / log(2));

    if(min_lat == max_lat || min_lat == max_lat || mapdisplay == 0)
        zoom = 11;

    //NSLog(@"setRegion %d %f %f %f %f %f", mapdisplay, min_lat, min_lon, max_lat, max_lon, zoom);
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:region.center.latitude
                                                            longitude:region.center.longitude zoom:zoom];
    animated ? [self animateToCameraPosition:camera] : [self setCamera:camera];
}

- (MKMapRect)visibleMapRect
{
    MKCoordinateRegion region = [self region];
    
    MKMapPoint a = MKMapPointForCoordinate(CLLocationCoordinate2DMake(
        region.center.latitude + region.span.latitudeDelta / 2,
        region.center.longitude - region.span.longitudeDelta / 2));
    
    MKMapPoint b = MKMapPointForCoordinate(CLLocationCoordinate2DMake(
        region.center.latitude - region.span.latitudeDelta / 2,
        region.center.longitude + region.span.longitudeDelta / 2));
    
    return MKMapRectMake(MIN(a.x, b.x), MIN(a.y, b.y), ABS(a.x - b.x), ABS(a.y - b.y));
}

@end
