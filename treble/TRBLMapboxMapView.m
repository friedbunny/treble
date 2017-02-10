//
//  TRBLMapboxMapView.m
//  treble
//
//  Created by Jason Wray on 4/30/15.
//  Copyright (c) 2015 Mapbox. All rights reserved.
//

#import "TRBLMapboxMapView.h"
#import "TRBLCoordinator.h"

#import "Constants.h"
#import "UITabBarController+Visible.h"

#import <Mapbox/Mapbox.h>

@interface TRBLMapboxMapView () <MGLMapViewDelegate, TRBLCoordinatorDelegate>

@property (nonatomic) IBOutlet MGLMapView *mapView;

@property TRBLCoordinator *coordinator;
@property (nonatomic) BOOL shouldUpdateCoordinates;

@end

@implementation TRBLMapboxMapView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.coordinator = [TRBLCoordinator sharedCoordinator];
    
    self.mapView.showsUserLocation = YES;
    self.mapView.userTrackingMode = MGLUserTrackingModeFollow;
    self.mapView.delegate = self;

    // Add tab bar controller toggle gesture
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleTabBarController:)];
    for (UIGestureRecognizer *recognizer in self.mapView.gestureRecognizers) {
        if ([recognizer isKindOfClass:[UITapGestureRecognizer class]]) {
            [singleTap requireGestureRecognizerToFail:recognizer];
        }
    }
    [self.mapView addGestureRecognizer:singleTap];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarTappedAction:) name:kStatusBarTappedNotification object:nil];

    // Observe NSUserDefaults changes
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(defaultsChanged:) name:NSUserDefaultsDidChangeNotification object:nil];
    [self defaultsChanged:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.coordinator.delegate = self;

    //NSLog(@"MB appear: %f,%f by %f,%f", self.coordinator.southWest.latitude, self.coordinator.southWest.longitude, self.coordinator.northEast.latitude, self.coordinator.northEast.longitude);
    
    if (self.coordinator.needsUpdateMapbox) {
        //NSLog(@"MB: Updating start coords");
        self.mapView.direction = self.coordinator.bearing;
        [self.mapView setVisibleCoordinateBounds:MGLCoordinateBoundsMake(self.coordinator.southWest, self.coordinator.northEast) animated:NO];
        self.coordinator.needsUpdateMapbox = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    if (self.shouldUpdateCoordinates) {
        self.coordinator.centerCoordinate = self.mapView.centerCoordinate;
        self.coordinator.bearing = self.mapView.direction;
        
        CLLocationCoordinate2D southWest = [self.mapView convertPoint:CGPointMake(0, self.view.bounds.size.height)
                                                 toCoordinateFromView:self.mapView];
        
        CLLocationCoordinate2D northEast = [self.mapView convertPoint:CGPointMake(self.mapView.bounds.size.width, 0)
                                                 toCoordinateFromView:self.mapView];
        
        self.coordinator.southWest = southWest;
        self.coordinator.northEast = northEast;
        
        [self.coordinator setNeedsUpdateFromVendor:TRBLMapVendorMapbox];
        self.shouldUpdateCoordinates = NO;
    }
    
    //NSLog(@"MB disappear: %f,%f by %f,%f", self.coordinator.southWest.latitude, self.coordinator.southWest.longitude, self.coordinator.northEast.latitude, self.coordinator.northEast.longitude);
    
    self.coordinator.delegate = nil;

    [[NSNotificationCenter defaultCenter] removeObserver:self name:kStatusBarTappedNotification object:nil];
}

- (void)mapView:(MGLMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    self.shouldUpdateCoordinates = YES;
}

- (void)mapShouldChangeStyle {
    [self cycleStyles];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (NSArray *)styles {
    static NSArray *_styles;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _styles = @[
            [MGLStyle streetsStyleURLWithVersion:MGLStyleDefaultVersion],
            [NSURL URLWithString:@"mapbox://styles/mapbox/traffic-day-v1"],
            [MGLStyle outdoorsStyleURLWithVersion:MGLStyleDefaultVersion],
            [MGLStyle lightStyleURLWithVersion:MGLStyleDefaultVersion],
            [MGLStyle darkStyleURLWithVersion:MGLStyleDefaultVersion],
            [NSURL URLWithString:@"mapbox://styles/mapbox/traffic-night-v1"],
            [MGLStyle satelliteStyleURLWithVersion:MGLStyleDefaultVersion],
            [MGLStyle satelliteStreetsStyleURLWithVersion:MGLStyleDefaultVersion],
        ];
    });
    
    return _styles;
}

- (void)cycleStyles {
    NSArray *styles = [self styles];
    NSURL *styleURL = self.mapView.styleURL;
    
    if (!styleURL) {
        styleURL = [[self styles] firstObject];
    } else {
        NSAssert([styles indexOfObject:styleURL] < [styles count], @"%@ is not indexed.", styleURL);
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
    [self.mapView setUserTrackingMode:MGLUserTrackingModeFollow animated:YES];
}

- (void)toggleTabBarController:(__unused UITapGestureRecognizer *)gestureRecognizer {
    [UIView animateWithDuration:0.15 animations:^{
        [self.tabBarController toggleTabBar];
        UIEdgeInsets newInsets = self.mapView.contentInset;
        newInsets.bottom = self.tabBarController.tabBarIsVisible ? self.tabBarController.tabBar.frame.size.height + 1 : 0;
        self.mapView.contentInset = newInsets;
    }];
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

/*
- (void)mapViewWillStartLoadingMap:(MGLMapView * __unused)mapView {
    NSLog(@"start LOADING");
}

- (void)mapViewDidFinishLoadingMap:(MGLMapView * __unused)mapView {
    NSLog(@"finish LOADING");
}

- (void)mapViewWillStartRenderingMap:(MGLMapView * __unused)mapView {
    NSLog(@"start RENDERING");
}

- (void)mapViewDidFinishRenderingMap:(MGLMapView * __unused)mapView fullyRendered:(BOOL)fullyRendered {
    NSLog(@"finish RENDERING fullyRendered: %@", fullyRendered ? @"YES":@"NO");
}
*/

@end
