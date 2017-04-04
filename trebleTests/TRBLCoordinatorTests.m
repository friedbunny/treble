//
//  TRBLCoordinatorTests.m
//  Treble
//
//  Created by Jason Wray on 4/4/17.
//  Copyright © 2017 Mapbox. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TRBLCoordinator.h"

@interface TRBLCoordinatorTests : XCTestCase <TRBLCoordinatorDelegate>

@property TRBLCoordinator *coordinator;
@property XCTestExpectation *delegateExpectation;

@end

@implementation TRBLCoordinatorTests

- (void)setUp {
    [super setUp];
    self.coordinator = TRBLCoordinator.sharedCoordinator;
}

- (void)tearDown {
    self.delegateExpectation = nil;
    [super tearDown];
}

- (void)testSetNeedsUpdateFromVendor {
    self.coordinator.needsUpdateMapbox = YES;
    XCTAssertTrue(self.coordinator.needsUpdateGoogle);
    XCTAssertTrue(self.coordinator.needsUpdateMapKit);
}

- (void)testMapShouldChangeStyle {
    self.delegateExpectation = [[XCTestExpectation alloc] initWithDescription:@"-mapShouldChangeStyle delegate method should be called"];
    self.coordinator.delegate = self;
    [self.coordinator.delegate mapShouldChangeStyle];
    [self waitForExpectations:@[self.delegateExpectation] timeout:1];
}

#pragma mark - TRBLCoordinatorDelegate methods

- (void)mapShouldChangeStyle {
    [self.delegateExpectation fulfill];
}

@end
