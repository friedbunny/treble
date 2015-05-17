//
//  TRBLCoordinator.h
//  Treble
//
//  Created by Jason Wray on 4/30/15.
//  Copyright (c) 2015 Mapbox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

typedef NS_ENUM(NSInteger, TRBLMapVendor) {
    TRBLMapVendorNone = 0,
    TRBLMapVendorMapbox,
    TRBLMapVendorMapKit,
    TRBLMapVendorGoogle,
};


@protocol TRBLCoordinatorDelegate <NSObject>

- (void)mapShouldChangeStyle;

@end


@interface TRBLCoordinator : NSObject

+ (TRBLCoordinator *)sharedCoordinator;
- (instancetype)init;

@property(nonatomic, assign) id<TRBLCoordinatorDelegate> delegate;

@property (nonatomic) NSString *mapboxAPIKey;

@property (nonatomic) CLLocationCoordinate2D centerCoordinate;
@property (nonatomic) CLLocationCoordinate2D northEast;
@property (nonatomic) CLLocationCoordinate2D southWest;
@property (nonatomic) CLLocationDirection bearing;

@property (nonatomic) BOOL needsUpdateMapbox;
@property (nonatomic) BOOL needsUpdateMapKit;
@property (nonatomic) BOOL needsUpdateGoogle;

- (void)setNeedsUpdateFromVendor:(TRBLMapVendor)vendor;

@end



