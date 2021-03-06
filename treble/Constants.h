//
//  Constants.h
//  Treble
//
//  Created by Jason Wray on 4/8/16.
//  Copyright © 2016 Mapbox. All rights reserved.
//

static NSString * const TRBLURLScheme = @"treble";
static NSUInteger const TRBLMapboxViewControllerIndex = 1;

static NSString * const kStatusBarTappedNotification = @"statusBarTappedNotification";

// NSUserDefaults
static NSString * const TRBLDefaultsUIAlwaysShowMapInfoLabel    = @"TRBLUIAlwaysShowMapInfoLabel";
static NSString * const TRBLDefaultsMapboxLocalizesStyle        = @"TRBLMapboxLocalizesStyle";
static NSString * const TRBLDefaultsDebugOptionsTileBoundaries  = @"TRBLDebugOptionsTileBoundaries";
static NSString * const TRBLDefaultsDebugOptionsTileInfo        = @"TRBLDebugOptionsTileInfo";
static NSString * const TRBLDefaultsDebugOptionsTileTimestamps  = @"TRBLDebugOptionsTileTimestamps";
static NSString * const TRBLDefaultsDebugOptionsCollisionBoxes  = @"TRBLDebugOptionsCollisionBoxes";

// Crashlytics metadata keys
static NSString * const TRBLCrashlyticsMetadataKeyActiveVendor  = @"activeVendor";

#if defined(__IPHONE_13_0) && (__IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_13_0)
#define TRBL_HAS_IOS_13_SUPPORT
#endif
