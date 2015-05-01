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
        self.currentLocation = CLLocationCoordinate2DMake(39.8282, -98.5795);
        self.currentZoom = 2.0f;
    }
    
    return self;
}

@end
