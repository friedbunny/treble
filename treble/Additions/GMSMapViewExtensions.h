//
//  GMSMapViewExtensions.h
//  http://stackoverflow.com/a/23808369/2094275
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <GoogleMaps/GoogleMaps.h>

@interface GMSMapView (GMSMapViewExtensions)

- (MKCoordinateRegion)region;
- (MKMapRect)visibleMapRect;

@end