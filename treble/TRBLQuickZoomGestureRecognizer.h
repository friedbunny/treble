//
//  TRBLQuickZoomGestureRecognizer.h
//  treble
//
//  Created by Jason Wray on 3/4/19.
//  Copyright © 2019 Jason Wray. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MapKit;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TRBLQuickZoomGestureZoomMode) {
    TRBLQuickZoomGestureZoomModeUpIn,  // MapKit
    TRBLQuickZoomGestureZoomModeUpOut, // Mapbox, Google
};

@interface TRBLQuickZoomGestureRecognizer : UILongPressGestureRecognizer

@property (nonatomic) TRBLQuickZoomGestureZoomMode zoomMode;

- (instancetype)initWithMapView:(nullable MKMapView *)mapView action:(nullable SEL)action NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
