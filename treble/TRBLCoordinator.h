//
//  TRBLCoordinator.h
//  Treble
//
//  Created by Jason Wray on 4/30/15.
//  Copyright (c) 2015 Mapbox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface TRBLCoordinator : NSObject

@property (nonatomic) NSString *mapboxAPIKey;

@property (nonatomic) CLLocationCoordinate2D currentLocation;
@property (nonatomic) float currentZoom;
@property (nonatomic) MKCoordinateRegion region;

+ (TRBLCoordinator *)sharedCoordinator;
- (instancetype)init;

@end
