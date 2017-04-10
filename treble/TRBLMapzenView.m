//
//  TRBLMapzenView.m
//  Treble
//
//  Created by Jason Wray on 3/13/17.
//  Copyright © 2017 Mapbox. All rights reserved.
//

#import "TRBLMapzenView.h"
#import "TRBLCoordinator.h"
#import "TRBLZoomLabelView.h"
#import "UITabBarController+Visible.h"

@interface TRBLMapzenView () <TGMapViewDelegate, TGRecognizerDelegate, TRBLCoordinatorDelegate> {
    TGSceneUpdate *_apiKey;
}

@property TRBLCoordinator *coordinator;
@property (nonatomic) BOOL shouldUpdateCoordinates;
@property (nonatomic) IBOutlet TRBLZoomLabelView *zoomLabelView;

@property (readonly) TGSceneUpdate *apiKey;
@property (nonatomic) NSString *currentScene;
@property (nonatomic) BOOL finishedInitialLoading;

@end

@implementation TRBLMapzenView

- (void)viewDidLoad {
    [super viewDidLoad];

    self.coordinator = [TRBLCoordinator sharedCoordinator];

    // Tangram-es delegates
    self.mapViewDelegate = self;
    self.gestureDelegate = self;

    [self cycleScenes];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.finishedInitialLoading = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    self.coordinator.delegate = self;

    if (self.coordinator.needsUpdateMapzen) {
//        [self.mapView fitBoundsToSouthWestCoordinate:self.coordinator.southWest northEastCoordinate:self.coordinator.northEast];
//        self.mapView.camera.heading = self.coordinator.bearing;
        self.coordinator.needsUpdateMapzen = NO;
    }

    //[self updateZoomLabel];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    if (self.shouldUpdateCoordinates) {
//        self.coordinator.southWest = self.mapView.southWestCoordinate;
//        self.coordinator.northEast = self.mapView.northEastCoordinate;
//        self.coordinator.centerCoordinate = self.mapView.centerCoordinate;
//        self.coordinator.bearing = self.mapView.camera.heading;

        [self.coordinator setNeedsUpdateFromVendor:TRBLMapVendorMapzen];
        self.shouldUpdateCoordinates = NO;
    }

    self.coordinator.delegate = nil;

    //[self resetZoomLabel];
}

- (NSArray *)scenes {
    static NSArray *_scenes;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _scenes = @[
            @"https://tangrams.github.io/bubble-wrap/bubble-wrap-style-more-labels.yaml",
            @"https://tangrams.github.io/cinnabar-style-more-labels/cinnabar-style-more-labels.yaml",
            @"https://tangrams.github.io/refill-style-more-labels/refill-style-more-labels.yaml",
            @"https://tangrams.github.io/walkabout-style-more-labels/walkabout-style-more-labels.yaml",
            @"https://tangrams.github.io/zinc-style-more-labels/zinc-style-more-labels.yaml",
            @"https://tangrams.github.io/tron-style/tron-style-more-labels.yaml",
            @"https://tangrams.github.io/transit-style/transit-style.yaml",
        ];
    });

    return _scenes;
}

- (void)cycleScenes {
    NSArray *scenes = [self scenes];
    NSString *scene = self.currentScene;

    if (!scene) {
        scene = [[self scenes] firstObject];
    } else {
        NSAssert([scenes indexOfObject:scene] < [scenes count], @"%@ is not indexed.", scene);
        NSUInteger index = [scenes indexOfObject:scene] + 1;
        if (index == [scenes count] || !index) index = 0;
        scene = [scenes objectAtIndex:index];
    }

    [self loadSceneFileAsync:scene sceneUpdates:@[self.apiKey]];
    self.currentScene = scene;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    UIStatusBarStyle statusBarStyle;
    NSString *scene = self.currentScene;

    if ([scene containsString:@"tron"]) {
        statusBarStyle = UIStatusBarStyleLightContent;
    } else {
        statusBarStyle = UIStatusBarStyleDefault;
    }
    
    return statusBarStyle;
}

- (TGSceneUpdate *)apiKey {
    if (!_apiKey) {
        NSDictionary *apiKeys = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"APIKeys" ofType:@"plist"]];
        NSString *mapzenAPIKey = [apiKeys objectForKey:@"Mapzen API Key"];
        return [[TGSceneUpdate alloc] initWithPath:@"global.sdk_mapzen_api_key" value:mapzenAPIKey];
    }

    return _apiKey;
}

#pragma mark - TRBLCoordinatorDelegate

- (void)mapShouldChangeStyle {
    [self cycleScenes];
    [self setNeedsStatusBarAppearanceUpdate];
}

#pragma mark - TGMapViewDelegate

-(void)mapViewDidCompleteLoading:(TGMapViewController *)mapView {
    if (self.finishedInitialLoading) {
        self.shouldUpdateCoordinates = YES;
    } else {
        self.finishedInitialLoading = YES;
    }
}

#pragma mark - TGRecognizerDelegate

-(BOOL)mapView:(TGMapViewController *)view recognizer:(UIGestureRecognizer *)recognizer shouldRecognizeSingleTapGesture:(CGPoint)location {
    [UIView animateWithDuration:0.15 animations:^{
        [self.tabBarController toggleTabBar];
    }];
    return false;
}

@end
