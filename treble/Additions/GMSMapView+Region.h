//
//  GMSMapView+Region.h
//  http://stackoverflow.com/a/23808369/2094275
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <GoogleMaps/GoogleMaps.h>

@interface GMSMapView (Region)

- (MKCoordinateRegion)region;
- (void)setRegion:(MKCoordinateRegion)region bearing:(CLLocationDegrees)bearing animated:(BOOL)animated;
- (MKMapRect)visibleMapRect;

@end