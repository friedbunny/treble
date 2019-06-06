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
};

typedef NS_ENUM(NSInteger, TRBLUserTrackingMode) {
    TRBLUserTrackingModeNone = 0,
    TRBLUserTrackingModeFollow,
    TRBLUserTrackingModeFollowWithHeading,
    TRBLUserTrackingModeFollowWithCourse,
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
@property (nonatomic) CLLocationDirection heading;
@property (nonatomic) double zoomLevel;
@property (nonatomic) CGFloat pitch;
@property (nonatomic) TRBLUserTrackingMode userTrackingMode;

@property (nonatomic) BOOL needsUpdateMapbox;
@property (nonatomic) BOOL needsUpdateMapKit;
@property (nonatomic) BOOL needsUpdateGoogle;

@property (nonatomic) NSString *activeVendor;

- (void)setNeedsUpdateFromVendor:(TRBLMapVendor)vendor;

@end
