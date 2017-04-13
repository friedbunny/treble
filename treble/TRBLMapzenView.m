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
#import <Mapbox/MGLGeometry.h>

static const double MAPZEN_ZOOM_OFFSET = 1;
static const double MAPZEN_ANIMATION_DURATION = 0.3;

@interface TRBLMapzenView () <TGMapViewDelegate, TGRecognizerDelegate, TRBLCoordinatorDelegate, UIGestureRecognizerDelegate> {
    TGSceneUpdate *_apiKey;
}

@property TRBLCoordinator *coordinator;
@property (nonatomic) BOOL shouldUpdateCoordinates;
@property (nonatomic) IBOutlet TRBLZoomLabelView *mapInfoView;

@property (readonly) TGSceneUpdate *apiKey;
@property (nonatomic) NSString *currentScene;
@property (nonatomic) BOOL finishedInitialLoading;
@property (nonatomic) UITapGestureRecognizer *twoFingerTapGesture;
@property (nonatomic) UIPanGestureRecognizer *twoFingerDragGesture;

@end

@implementation TRBLMapzenView

- (void)viewDidLoad {
    [super viewDidLoad];

    self.coordinator = [TRBLCoordinator sharedCoordinator];

    // Tangram-es delegates
    self.mapViewDelegate = self;
    self.gestureDelegate = self;

    // Does not load a style/scene initially.
    [self cycleScenes];

    [self setupCustomGestures];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(defaultsChanged:) name:NSUserDefaultsDidChangeNotification object:nil];
    [self defaultsChanged:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.finishedInitialLoading = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    self.coordinator.delegate = self;

    if (self.coordinator.needsUpdateMapzen) {
        self.position = TGGeoPointMake(self.coordinator.centerCoordinate.longitude, self.coordinator.centerCoordinate.latitude);
        self.rotation = MGLRadiansFromDegrees(self.coordinator.heading) * -1;
        self.zoom = self.coordinator.zoomLevel + MAPZEN_ZOOM_OFFSET;
        self.tilt = MGLRadiansFromDegrees(self.coordinator.pitch);
        self.coordinator.needsUpdateMapzen = NO;
    }

    [self updateMapInfoViewAnimated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    if (self.shouldUpdateCoordinates) {
        self.coordinator.centerCoordinate = CLLocationCoordinate2DMake(self.position.latitude, self.position.longitude);
        self.coordinator.heading = MGLDegreesFromRadians(self.rotation) * -1;
        self.coordinator.zoomLevel = self.zoom - MAPZEN_ZOOM_OFFSET;
        self.coordinator.pitch = MGLDegreesFromRadians(self.tilt);

        [self.coordinator setNeedsUpdateFromVendor:TRBLMapVendorMapzen];
        self.shouldUpdateCoordinates = NO;
    }

    self.coordinator.delegate = nil;
}

- (void)updateMapInfoViewAnimated:(BOOL)animated {
    if (!animated) {
        self.mapInfoView.alpha = 1;
    }
    self.mapInfoView.zoomLevel = self.zoom;
    self.mapInfoView.pitch = MGLDegreesFromRadians(self.tilt);
}

- (void)defaultsChanged:(__unused NSNotification *)notification {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    self.mapInfoView.hidden = ![defaults boolForKey:@"TRBLUIZoomLevel"];
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

- (void)setupCustomGestures {
    // Two finger tap-to-zoom-out
    self.twoFingerTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwoFingerTap)];
    self.twoFingerTapGesture.numberOfTouchesRequired = 2;
    self.twoFingerTapGesture.delegate = self;
    [self.view addGestureRecognizer:self.twoFingerTapGesture];

    // Hook the built-in two finger drag-to-tilt gesture.
    // Add simultaneously-recognized pitch/tilt gesture to update the map info label.
    self.twoFingerDragGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwoFingerDrag)];
    self.twoFingerDragGesture.minimumNumberOfTouches = 2;
    self.twoFingerDragGesture.maximumNumberOfTouches = 2;
    self.twoFingerDragGesture.delegate = self;
    [self.view addGestureRecognizer:self.twoFingerDragGesture];
}

- (void)handleTwoFingerTap {
    [self animateToZoomLevel:round(self.zoom) - 1 withDuration:MAPZEN_ANIMATION_DURATION withEaseType:TGEaseTypeCubic];
}

- (void)handleTwoFingerDrag {
    [self updateMapInfoViewAnimated:YES];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (gestureRecognizer == self.twoFingerTapGesture || otherGestureRecognizer == self.twoFingerTapGesture) {
        return NO;
    } else if (gestureRecognizer == self.twoFingerDragGesture && [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        return ((UIPanGestureRecognizer *)otherGestureRecognizer).minimumNumberOfTouches == 2;
    }
    return [super gestureRecognizer:gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:otherGestureRecognizer];
}

#pragma mark - TRBLCoordinatorDelegate

- (void)mapShouldChangeStyle {
    [self cycleScenes];
    [self setNeedsStatusBarAppearanceUpdate];
}

#pragma mark - TGMapViewDelegate

- (void)mapViewDidCompleteLoading:(TGMapViewController *)mapView {
    if (self.finishedInitialLoading) {
        self.shouldUpdateCoordinates = YES;
    } else {
        self.finishedInitialLoading = YES;
    }

    [self updateMapInfoViewAnimated:YES];
}

#pragma mark - TGRecognizerDelegate

- (BOOL)mapView:(TGMapViewController *)view recognizer:(UIGestureRecognizer *)recognizer shouldRecognizeSingleTapGesture:(CGPoint)location {
    [self.tabBarController toggleTabBarAnimated:YES];
    return NO;
}

- (void)mapView:(TGMapViewController *)view recognizer:(UIGestureRecognizer *)recognizer didRecognizePinchGesture:(CGPoint)location {
    [self updateMapInfoViewAnimated:YES];
}

- (void)mapView:(TGMapViewController *)view recognizer:(UIGestureRecognizer *)recognizer didRecognizeDoubleTapGesture:(CGPoint)location {
    // Umm, for some reason Mapzen apparently hasn't implemented double-tap-to-zoom yet.
    [view animateToZoomLevel:round(view.zoom) + 1 withDuration:MAPZEN_ANIMATION_DURATION withEaseType:TGEaseTypeCubic];
    [view animateToPosition:[view screenPositionToLngLat:location] withDuration:MAPZEN_ANIMATION_DURATION withEaseType:TGEaseTypeCubic];
}

@end
