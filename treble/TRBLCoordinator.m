//
//  TRBLCoordinator.m
//  Treble
//
//  Created by Jason Wray on 4/30/15.
//  Copyright (c) 2015 Mapbox. All rights reserved.
//

#import "TRBLCoordinator.h"

@implementation TRBLCoordinator

+ (TRBLCoordinator *)sharedCoordinator
{
    static TRBLCoordinator *_sharedCoordinator = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedCoordinator = [[self alloc] init];
    });
    
    return _sharedCoordinator;
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.centerCoordinate = kCLLocationCoordinate2DInvalid;
        self.bearing = 0;
        self.southWest = CLLocationCoordinate2DMake(37.355402, -125.091839);
        self.northEast = CLLocationCoordinate2DMake(49.279846, -115.811519);
        [self setNeedsUpdateFromVendor:TRBLMapVendorNone];
    }
    
    return self;
}

- (void)setNeedsUpdateFromVendor:(TRBLMapVendor)vendor
{
    switch (vendor) {
        case TRBLMapVendorMapbox:
            self.needsUpdateMapKit = self.needsUpdateGoogle = YES;
            break;
            
        case TRBLMapVendorMapKit:
            self.needsUpdateMapbox = self.needsUpdateGoogle = YES;
            break;
            
        case TRBLMapVendorGoogle:
            self.needsUpdateMapbox = self.needsUpdateMapKit = YES;
            break;
        
        case TRBLMapVendorNone:
            self.needsUpdateMapbox = self.needsUpdateMapKit = self.needsUpdateGoogle = YES;
            break;
    }
}

@end
