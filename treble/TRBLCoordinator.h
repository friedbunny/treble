//
//  TRBLCoordinator.h
//  Treble
//
//  Created by Jason Wray on 4/30/15.
//  Copyright (c) 2015 Mapbox. All rights reserved.
//

@import Foundation;
@import MapKit;

typedef NS_ENUM(NSInteger, TRBLMapVendor) {
    TRBLMapVendorNone = 0,
    TRBLMapVendorMapbox,
    TRBLMapVendorMapKit,
    TRBLMapVendorGoogle,
    TRBLMapVendorMapzen,
};


@protocol TRBLCoordinatorDelegate <NSObject>

- (void)mapShouldChangeStyle;

@end


@interface TRBLCoordinator : NSObject

+ (TRBLCoordinator *)sharedCoordinator;
- (instancetype)init;

/**
    The delegate should be set in -viewDidAppear:animated:, as the delegate will
    be traded between already-instantiated view controllers (meaning -viewDidLoad
    will not be called).
 */
@property (nonatomic, assign) id<TRBLCoordinatorDelegate> delegate;

@property (nonatomic) CLLocationCoordinate2D centerCoordinate;
@property (nonatomic) CLLocationDirection bearing;
@property (nonatomic) double zoomLevel;
@property (nonatomic) CGFloat pitch;

@property (nonatomic) BOOL needsUpdateMapbox;
@property (nonatomic) BOOL needsUpdateMapKit;
@property (nonatomic) BOOL needsUpdateGoogle;
@property (nonatomic) BOOL needsUpdateMapzen;

- (void)setNeedsUpdateFromVendor:(TRBLMapVendor)vendor;

@end
