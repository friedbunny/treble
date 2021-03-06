//
//  TRBLMapboxMapView.m
//  treble
//
//  Created by Jason Wray on 4/30/15.
//  Copyright (c) 2015 Mapbox. All rights reserved.
//

#import "TRBLMapboxMapView.h"
#import "TRBLCoordinator.h"
#import "TRBLZoomLabelView.h"
#import "TRBLStyleLabelView.h"

#import "Constants.h"
#import "UITabBarController+Visible.h"

@import Mapbox;
#import <NSTimeZone+Coordinate.h>

@interface TRBLMapboxMapView () <MGLMapViewDelegate, TRBLCoordinatorDelegate>

@property (nonatomic) IBOutlet MGLMapView *mapView;

@property TRBLCoordinator *coordinator;
@property (nonatomic) BOOL shouldUpdateCoordinates;

@property (nonatomic) IBOutlet TRBLZoomLabelView *mapInfoView;
@property (nonatomic) IBOutlet TRBLStyleLabelView *styleLabelView;

@end

@implementation TRBLMapboxMapView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.coordinator = [TRBLCoordinator sharedCoordinator];
    
    self.mapView.showsUserLocation = YES;
    self.mapView.showsUserHeadingIndicator = YES;
    self.mapView.delegate = self;

    // Default to the first style in our list.
    [self.mapView setStyleURL:[self styles].firstObject];

    // Disable content insets so that the center coordinate is consistent across vendors.
    self.automaticallyAdjustsScrollViewInsets = NO;

    // Center the map on the largest city in the user’s time zone.
    CLLocationCoordinate2D locationFromTimeZone = NSTimeZone.localTimeZone.coordinate;
    if (CLLocationCoordinate2DIsValid(locationFromTimeZone)) {
        [self.mapView setCenterCoordinate:locationFromTimeZone zoomLevel:3.0 animated:NO];
    }

    // Add tab bar controller toggle gesture
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleTabBarController:)];
    for (UIGestureRecognizer *recognizer in self.mapView.gestureRecognizers) {
        if ([recognizer isKindOfClass:[UITapGestureRecognizer class]]) {
            [singleTap requireGestureRecognizerToFail:recognizer];
        }
    }
    [self.mapView addGestureRecognizer:singleTap];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(defaultsChanged:) name:NSUserDefaultsDidChangeNotification object:nil];
    [self defaultsChanged:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.coordinator.delegate = self;
    self.coordinator.activeVendor = @"mapbox";

    if (self.coordinator.needsUpdateMapbox) {
        self.mapView.zoomLevel = self.coordinator.zoomLevel;
        MGLMapCamera *camera = self.mapView.camera;
        camera.centerCoordinate = self.coordinator.centerCoordinate;
        camera.heading = self.coordinator.heading;
        camera.pitch = self.coordinator.pitch;
        self.mapView.camera = camera;
        self.mapView.userTrackingMode = (MGLUserTrackingMode)self.coordinator.userTrackingMode;

        self.coordinator.needsUpdateMapbox = NO;
    }

    [self updateMapInfoViewAnimated:NO];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarTappedAction:) name:kStatusBarTappedNotification object:nil];
}

- (CLLocationCoordinate2D)centerCoordinate {
    return [self.mapView convertPoint:self.view.center toCoordinateFromView:self.mapView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    if (self.shouldUpdateCoordinates) {
        self.coordinator.centerCoordinate = self.mapView.centerCoordinate;
        self.coordinator.heading = self.mapView.direction;
        self.coordinator.zoomLevel = self.mapView.zoomLevel;
        self.coordinator.pitch = self.mapView.camera.pitch;
        self.coordinator.userTrackingMode = (TRBLUserTrackingMode)self.mapView.userTrackingMode;
        
        [self.coordinator setNeedsUpdateFromVendor:TRBLMapVendorMapbox];
        self.shouldUpdateCoordinates = NO;
    }
    
    self.coordinator.delegate = nil;

    [[NSNotificationCenter defaultCenter] removeObserver:self name:kStatusBarTappedNotification object:nil];
}

- (void)mapView:(MGLMapView *)mapView didFinishLoadingStyle:(MGLStyle *)style {
    if ([NSUserDefaults.standardUserDefaults boolForKey:TRBLDefaultsMapboxLocalizesStyle]) {
        [style localizeLabelsIntoLocale:nil];
    }
}

- (void)mapView:(MGLMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    self.shouldUpdateCoordinates = YES;
    [self updateMapInfoViewAnimated:YES];
}

- (void)mapViewRegionIsChanging:(MGLMapView *)mapView {
    [self updateMapInfoViewAnimated:YES];
}

- (void)updateMapInfoViewAnimated:(BOOL)animated {
    if (!animated) {
        self.mapInfoView.alpha = 1;
    }
    self.mapInfoView.zoomLevel = self.mapView.zoomLevel;
    self.mapInfoView.pitch = self.mapView.camera.pitch;
}

- (void)updateStyleLabelView {
    self.styleLabelView.styleName = /*self.mapView.style.name ?: */self.mapView.styleURL.lastPathComponent;
}

- (void)mapShouldChangeStyle {
    [self cycleStyles];
    [self updateStyleLabelView];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (NSArray<NSURL *> *)styles {
    static NSArray<NSURL *> *_styles;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _styles = @[
            [MGLStyle streetsStyleURL],
            [MGLStyle outdoorsStyleURL],
            [MGLStyle lightStyleURL],
            [MGLStyle darkStyleURL],
            [MGLStyle satelliteStyleURL],
            [MGLStyle satelliteStreetsStyleURL],
            [NSURL URLWithString:@"mapbox://styles/mapbox/navigation-preview-day-v4"],
            [NSURL URLWithString:@"mapbox://styles/mapbox/navigation-guidance-day-v4"],
            [NSURL URLWithString:@"mapbox://styles/mapbox/navigation-preview-night-v4"],
            [NSURL URLWithString:@"mapbox://styles/mapbox/navigation-guidance-night-v4"],
        ];
    });
    
    return _styles;
}

- (void)cycleStyles {
    NSArray<NSURL *> *styles = [self styles];
    NSURL *styleURL = self.mapView.styleURL;
    
    if (!styleURL) {
        styleURL = styles.firstObject;
    } else {
        NSAssert([styles indexOfObject:styleURL] < styles.count, @"%@ is not indexed.", styleURL);
        NSUInteger index = [styles indexOfObject:styleURL] + 1;
        if (index == styles.count || !index) index = 0;
        styleURL = [styles objectAtIndex:index];
    }
    
    self.mapView.styleURL = styleURL;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    UIStatusBarStyle statusBarStyle;
    NSString *mapStyle = self.mapView.styleURL.absoluteString;

    if ([mapStyle containsString:@"dark"] ||
        [mapStyle containsString:@"satellite"] ||
        [mapStyle containsString:@"night"]) {
        statusBarStyle = UIStatusBarStyleLightContent;
    } else {
#ifdef TRBL_HAS_IOS_13_SUPPORT
        if (@available(iOS 13.0, *)) {
            statusBarStyle = UIStatusBarStyleDarkContent;
        } else {
            statusBarStyle = UIStatusBarStyleDefault;
        }
#else
        statusBarStyle = UIStatusBarStyleDefault;
#endif
    }

    return statusBarStyle;
}

- (void)statusBarTappedAction:(__unused NSNotification *)notification {
    [self cycleUserTrackingModes];
}

- (void)cycleUserTrackingModes {
    MGLUserTrackingMode nextMode;
    switch (self.mapView.userTrackingMode) {
        case MGLUserTrackingModeNone:
            nextMode = MGLUserTrackingModeFollow;
            break;
        case MGLUserTrackingModeFollow:
            nextMode = MGLUserTrackingModeFollowWithHeading;
            break;
        case MGLUserTrackingModeFollowWithHeading:
            nextMode = MGLUserTrackingModeFollowWithCourse;
            break;
        case MGLUserTrackingModeFollowWithCourse:
            nextMode = MGLUserTrackingModeFollow;
            break;
    }
    [self.mapView setUserTrackingMode:nextMode animated:YES];
}

- (void)toggleTabBarController:(__unused UITapGestureRecognizer *)gestureRecognizer {
    [self.tabBarController toggleTabBarAnimated:YES];
}

- (void)mapView:(MGLMapView *)mapView didSelectAnnotation:(nonnull id<MGLAnnotation>)annotation {
    if ([annotation isKindOfClass:[MGLUserLocation class]]) {
        [self cycleUserTrackingModes];
        [self.mapView deselectAnnotation:annotation animated:NO];
    }
}

- (void)defaultsChanged:(__unused NSNotification *)notification {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    if ([defaults boolForKey:TRBLDefaultsMapboxLocalizesStyle]) {
        [self.mapView.style localizeLabelsIntoLocale:nil];
    } else {
        [self.mapView reloadStyle:nil];
    }

    MGLMapDebugMaskOptions debugMask = 0;

    if ([defaults boolForKey:TRBLDefaultsDebugOptionsTileBoundaries]) {
        debugMask ^= MGLMapDebugTileBoundariesMask;
    }
    if ([defaults boolForKey:TRBLDefaultsDebugOptionsTileInfo]) {
        debugMask ^= MGLMapDebugTileInfoMask;
    }
    if ([defaults boolForKey:TRBLDefaultsDebugOptionsTileTimestamps]) {
        debugMask ^= MGLMapDebugTimestampsMask;
    }
    if ([defaults boolForKey:TRBLDefaultsDebugOptionsCollisionBoxes]) {
        debugMask ^= MGLMapDebugCollisionBoxesMask;
    }

    self.mapView.debugMask = debugMask;
}

#pragma mark - URL schemes

- (BOOL)loadMapFromURLScheme:(NSURL *)url {
    NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:false];

    if (!urlComponents) {
        return NO;
    }

    // Parse query parameters.
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (urlComponents.queryItems) {
        for (NSURLQueryItem *item in urlComponents.queryItems) {
            params[item.name] = item.value;
        }
    }

    if ([params[@"zoom"] doubleValue]) {
        self.mapView.zoomLevel = [params[@"zoom"] doubleValue];
    }

    MGLMapCamera *camera = self.mapView.camera;
    if ([params[@"lat"] doubleValue] && [params[@"lng"] doubleValue]) {
        camera.centerCoordinate = CLLocationCoordinate2DMake([params[@"lat"] doubleValue], [params[@"lng"] doubleValue]);
    }
    if ([params[@"bearing"] doubleValue]) {
        camera.heading = [params[@"bearing"] doubleValue];
    }
    if ([params[@"pitch"] doubleValue]) {
        camera.pitch = [params[@"pitch"] doubleValue];
    }
    self.mapView.camera = camera;

    // Make this view controller active.
    if (self.tabBarController.selectedIndex != TRBLMapboxViewControllerIndex) {
        self.tabBarController.selectedIndex = TRBLMapboxViewControllerIndex;
    }

    // Wipe out any pending viewport changes.
    self.coordinator.needsUpdateMapbox = NO;

    return YES;
}

@end
