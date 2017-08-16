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

    if (self.coordinator.needsUpdateMapbox) {
        self.mapView.zoomLevel = self.coordinator.zoomLevel;
        MGLMapCamera *camera = self.mapView.camera;
        camera.centerCoordinate = self.coordinator.centerCoordinate;
        camera.heading = self.coordinator.heading;
        camera.pitch = self.coordinator.pitch;
        self.mapView.camera = camera;
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
        
        [self.coordinator setNeedsUpdateFromVendor:TRBLMapVendorMapbox];
        self.shouldUpdateCoordinates = NO;
    }
    
    self.coordinator.delegate = nil;

    [[NSNotificationCenter defaultCenter] removeObserver:self name:kStatusBarTappedNotification object:nil];
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

- (NSArray *)styles {
    static NSArray *_styles;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _styles = @[
            [MGLStyle streetsStyleURLWithVersion:10],
            [MGLStyle outdoorsStyleURLWithVersion:10],
            [MGLStyle lightStyleURLWithVersion:9],
            [MGLStyle darkStyleURLWithVersion:9],
            [MGLStyle satelliteStyleURLWithVersion:9],
            [MGLStyle satelliteStreetsStyleURLWithVersion:10],
            [NSURL URLWithString:@"mapbox://styles/mapbox/navigation-preview-day-v2"],
            [NSURL URLWithString:@"mapbox://styles/mapbox/navigation-guidance-day-v2"],
            [NSURL URLWithString:@"mapbox://styles/mapbox/navigation-preview-night-v2"],
            [NSURL URLWithString:@"mapbox://styles/mapbox/navigation-guidance-night-v2"],
        ];
    });
    
    return _styles;
}

- (void)cycleStyles {
    NSArray *styles = [self styles];
    NSURL *styleURL = self.mapView.styleURL;
    
    if (!styleURL) {
        styleURL = [self styles].firstObject;
    } else {
        NSAssert([styles indexOfObject:styleURL] < styles.count, @"%@ is not indexed.", styleURL);
        NSUInteger index = [styles indexOfObject:styleURL] + 1;
        if (index == [styles count] || !index) index = 0;
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
        statusBarStyle = UIStatusBarStyleDefault;
    }

    return statusBarStyle;
}

- (void)statusBarTappedAction:(__unused NSNotification*)notification {
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

- (void)mapView:(__unused MGLMapView *)mapView didFailToLocateUserWithError:(__unused NSError *)error {
    // iOS 8+: Prompt users to open Settings.app if authorization was denied
    if (!self.presentedViewController) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Requires Authorization"
                                                                       message:@"Please enable location services for this app in Privacy settings."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                         style:UIAlertActionStyleCancel
                                                       handler:nil];

        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Open Settings"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(__unused UIAlertAction *action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }];

        [alert addAction:cancel];
        [alert addAction:ok];

        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)defaultsChanged:(__unused NSNotification *)notification {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    MGLMapDebugMaskOptions debugMask = 0;

    if ([defaults boolForKey:@"TRBLDebugOptionsTileBoundaries"]) {
        debugMask ^= MGLMapDebugTileBoundariesMask;
    }
    if ([defaults boolForKey:@"TRBLDebugOptionsTileInfo"]) {
        debugMask ^= MGLMapDebugTileInfoMask;
    }
    if ([defaults boolForKey:@"TRBLDebugOptionsTileTimestamps"]) {
        debugMask ^= MGLMapDebugTimestampsMask;
    }
    if ([defaults boolForKey:@"TRBLDebugOptionsCollisionBoxes"]) {
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
