//
//  TRBLQuickZoomGestureRecognizer.m
//  treble
//
//  Created by Jason Wray on 3/4/19.
//  Copyright © 2019 Jason Wray. All rights reserved.
//

@import MapKit;

#import "TRBLQuickZoomGestureRecognizer.h"
#import "Additions/MKMapView+ZoomLevel.h"

@interface TRBLQuickZoomGestureRecognizer ()

@property (nonatomic) CGFloat scale;
@property (nonatomic) CGFloat start;
@property (nonatomic) CGFloat minimumZoom;

@end

@implementation TRBLQuickZoomGestureRecognizer

- (instancetype)initWithMapView:(MKMapView *)mapView action:(SEL)action {
    if (self = [super initWithTarget:mapView action:action]) {
        self.numberOfTapsRequired = 1;
        self.minimumPressDuration = 0;
        self.zoomMode = TRBLQuickZoomGestureZoomModeUpIn;
        self.minimumZoom = 2.0;

        if (![mapView isKindOfClass:[MKMapView class]]) {
            [NSException raise:@"TRBLQuickZoomTargetMismatchException"
                        format:@"Target should be a kind of MKMapView, not %@.", [mapView class]];
        }
    }

    return self;
}

- (instancetype)initWithTarget:(id)target action:(SEL)action {
    return [self initWithMapView:target action:action];
}

- (void)reset {
    [super reset];

    self.scale = 0;
    self.start = 0;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];

    MKMapView *targetMapView = (MKMapView *)self.view;

    // Flyover map types use a different projection that our zoom conversion category can't handle.
    if (!targetMapView.isZoomEnabled || targetMapView.mapType == MKMapTypeSatelliteFlyover || targetMapView.mapType == MKMapTypeHybridFlyover) {
        self.state = UIGestureRecognizerStateFailed;
        return;
    }

    self.scale = powf(2, targetMapView.zoomLevel);
    self.start = [self locationInView:self.view].y;
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];

    if (self.numberOfTouches != self.numberOfTouchesRequired) return;

    MKMapView *targetMapView = (MKMapView *)self.view;

    CGFloat distance;
    switch (self.zoomMode) {
        case TRBLQuickZoomGestureZoomModeUpIn:
            distance = self.start - [self locationInView:self.view].y;
            break;

        case TRBLQuickZoomGestureZoomModeUpOut:
            distance = [self locationInView:self.view].y - self.start;
            break;
    }

    CGFloat newZoom = fmax(log2f(self.scale) + (distance / 75), self.minimumZoom);

    if (targetMapView.zoomLevel == newZoom) return;

    targetMapView.zoomLevel = newZoom;
}

- (BOOL)shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    [super shouldRequireFailureOfGestureRecognizer:otherGestureRecognizer];

    if ([otherGestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        return ((UITapGestureRecognizer *)otherGestureRecognizer).numberOfTapsRequired == 2;
    }
    return NO;
}

- (BOOL)shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    [super shouldBeRequiredToFailByGestureRecognizer:otherGestureRecognizer];

    if ([otherGestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        return ((UITapGestureRecognizer *)otherGestureRecognizer).numberOfTapsRequired == 1;
    }
    return NO;
}

@end
