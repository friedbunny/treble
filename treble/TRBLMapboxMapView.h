//
//  TRBLMapboxMapView.h
//  treble
//
//  Created by Jason Wray on 4/30/15.
//  Copyright (c) 2015 Mapbox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapboxGL/MapboxGL.h>

@interface TRBLMapboxMapView : UIViewController


@end


// hook up private API, in absence of public bounds-setting
@interface MGLMapView ()

- (void)zoomToSouthWestCoordinate:(CLLocationCoordinate2D)southWestCoordinate northEastCoordinate:(CLLocationCoordinate2D)northEastCoordinate animated:(BOOL)animated;
- (CGPoint)convertCoordinate:(CLLocationCoordinate2D)coordinate toPointToView:(UIView *)view;

@end
