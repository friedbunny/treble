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

static const double MAPZEN_ZOOM_OFFSET = 1;

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

    // Does not load a style/scene initially.
    [self cycleScenes];

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
        self.rotation = self.coordinator.bearing;
        self.zoom = self.coordinator.zoomLevel + MAPZEN_ZOOM_OFFSET;
        self.coordinator.needsUpdateMapzen = NO;
    }

    [self updateZoomLabel];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    if (self.shouldUpdateCoordinates) {
        self.coordinator.centerCoordinate = CLLocationCoordinate2DMake(self.position.latitude, self.position.longitude);
        self.coordinator.bearing = self.rotation;
        self.coordinator.zoomLevel = self.zoom - MAPZEN_ZOOM_OFFSET;

        [self.coordinator setNeedsUpdateFromVendor:TRBLMapVendorMapzen];
        self.shouldUpdateCoordinates = NO;
    }

    self.coordinator.delegate = nil;

    [self resetZoomLabel];
}

- (void)updateZoomLabel {
    self.zoomLabelView.zoomLevel = self.zoom;
}

- (void)resetZoomLabel {
    self.zoomLabelView.zoomLevel = 0;
}

- (void)defaultsChanged:(__unused NSNotification *)notification {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    self.zoomLabelView.hidden = ![defaults boolForKey:@"TRBLUIZoomLevel"];
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

- (void)mapViewDidCompleteLoading:(TGMapViewController *)mapView {
    if (self.finishedInitialLoading) {
        self.shouldUpdateCoordinates = YES;
    } else {
        self.finishedInitialLoading = YES;
    }

    [self updateZoomLabel];
}

#pragma mark - TGRecognizerDelegate

- (BOOL)mapView:(TGMapViewController *)view recognizer:(UIGestureRecognizer *)recognizer shouldRecognizeSingleTapGesture:(CGPoint)location {
    [self.tabBarController toggleTabBarAnimated:YES];
    return NO;
}

- (void)mapView:(TGMapViewController *)view recognizer:(UIGestureRecognizer *)recognizer didRecognizePinchGesture:(CGPoint)location {
    [self updateZoomLabel];
}

- (void)mapView:(TGMapViewController *)view recognizer:(UIGestureRecognizer *)recognizer didRecognizeDoubleTapGesture:(CGPoint)location {
    // Umm, for some reason Mapzen apparently hasn't implemented double-tap-to-zoom yet.
    [view animateToZoomLevel:round(view.zoom) + 1 withDuration:0.3 withEaseType:TGEaseTypeQuint];
    [view animateToPosition:[view screenPositionToLngLat:location] withDuration:0.3 withEaseType:TGEaseTypeQuint];
}

@end
