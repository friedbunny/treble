//
//  TRBLCoordinator.m
//  Treble
//
//  Created by Jason Wray on 4/30/15.
//  Copyright (c) 2015 Mapbox. All rights reserved.
//

#import "TRBLCoordinator.h"

@implementation TRBLCoordinator

+ (TRBLCoordinator *)sharedCoordinator {
    static TRBLCoordinator *_sharedCoordinator = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedCoordinator = [[self alloc] init];
    });
    
    return _sharedCoordinator;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.centerCoordinate = kCLLocationCoordinate2DInvalid;
        self.heading = 0;
        self.zoomLevel = 0;
        self.pitch = 0;
        self.userTrackingMode = TRBLUserTrackingModeNone;
        [self setNeedsUpdateFromVendor:TRBLMapVendorMapbox];
    }
    
    return self;
}

- (void)setNeedsUpdateFromVendor:(TRBLMapVendor)vendor {
    switch (vendor) {
        case TRBLMapVendorNone:
            self.needsUpdateMapbox = self.needsUpdateMapKit = self.needsUpdateGoogle = YES;
            break;

        case TRBLMapVendorMapbox:
            self.needsUpdateMapKit = self.needsUpdateGoogle = YES;
            break;
            
        case TRBLMapVendorMapKit:
            self.needsUpdateMapbox = self.needsUpdateGoogle = YES;
            break;
            
        case TRBLMapVendorGoogle:
            self.needsUpdateMapbox = self.needsUpdateMapKit = YES;
            break;
    }
}

- (void)setDelegate:(id<TRBLCoordinatorDelegate>)delegate {
    if (_delegate == delegate) return;
    _delegate = delegate;
}

@end
