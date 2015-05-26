//
//  TRBLMapboxMapView.m
//  treble
//
//  Created by Jason Wray on 4/30/15.
//  Copyright (c) 2015 Mapbox. All rights reserved.
//

#import "TRBLMapboxMapView.h"
#import "TRBLCoordinator.h"

static NSString *const kStyleVersion = @"7";

@interface TRBLMapboxMapView () <MGLMapViewDelegate, TRBLCoordinatorDelegate>

@property (nonatomic) IBOutlet MGLMapView *mapView;
@property (nonatomic) IBOutlet UIToolbar *toolbar;

@property (nonatomic) NSString *currentStyle;
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
    
    self.currentStyle = [[self styles] firstObject];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.coordinator.delegate = self;
    
    [self updateStatusBarStyleForMapStyle];

    //NSLog(@"MB appear: %f,%f by %f,%f", self.coordinator.southWest.latitude, self.coordinator.southWest.longitude, self.coordinator.northEast.latitude, self.coordinator.northEast.longitude);
    
    if (self.coordinator.needsUpdateMapbox)
    {
        NSLog(@"MB: Updating start coords");
        
        self.mapView.direction = self.coordinator.bearing;
        
        [self.mapView fitBoundsToSouthWestCoordinate:self.coordinator.southWest northEastCoordinate:self.coordinator.northEast padding:0 animated:NO];
        
        //self.mapView.direction = self.coordinator.bearing;
        
        self.coordinator.needsUpdateMapbox = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    if (self.shouldUpdateCoordinates)
    {
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
}

- (void)mapView:(MGLMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    self.shouldUpdateCoordinates = YES;
}

- (void)mapShouldChangeStyle
{
    [self cycleStyles];
    [self updateStatusBarStyleForMapStyle];
}

- (NSArray *)styles
{
    static NSArray *_styles;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _styles = @[
                    @"Mapbox Streets",
                    @"Emerald",
                    @"Light",
                    @"Dark",
                    ];
    });
    
    return _styles;
}

- (void)cycleStyles
{
    NSString *styleName = self.currentStyle;
    
    if ( ! styleName)
    {
        styleName = [[self styles] firstObject];
    }
    else
    {
        NSUInteger index = [[self styles] indexOfObject:styleName] + 1;
        if (index == [[self styles] count]) index = 0;
        styleName = [[self styles] objectAtIndex:index];
    }
    
    self.mapView.styleURL = [NSURL URLWithString:
                             [NSString stringWithFormat:@"asset://styles/%@-v%@.json",
                              [[styleName lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@"-"],
                              kStyleVersion]];
    
    self.currentStyle = styleName;
}

- (void)updateStatusBarStyleForMapStyle
{
    UIStatusBarStyle style;
    
    if ([self.currentStyle isEqualToString:@"Dark"])
    {
        style = UIStatusBarStyleLightContent;
    }
    else
    {
        style = UIStatusBarStyleDefault;
    }

    [[UIApplication sharedApplication] setStatusBarStyle:style animated:NO];
}

- (void)mapView:(__unused MGLMapView *)mapView didFailToLocateUserWithError:(__unused NSError *)error
{
    // iOS 8+: Prompt users to open Settings.app if authorization was denied
    if (&UIApplicationOpenSettingsURLString != NULL)
    {
        if ( ! self.presentedViewController)
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Requires Authorization"
                                                                           message:@"Please enable location services for this app in Privacy settings."
                                                                    preferredStyle:UIAlertControllerStyleAlert];

            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                             style:UIAlertActionStyleCancel
                                                           handler:nil];

            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Open Settings"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(__unused UIAlertAction *action)
                                 {
                                     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                                 }];

            [alert addAction:cancel];
            [alert addAction:ok];

            [self presentViewController:alert animated:YES completion:nil];
        }
    }
    else
    {
        if ( ! self.presentedViewController)
        {
            [[[UIAlertView alloc] initWithTitle:@"Requires Authorization"
                                        message:@"Please enable location services for this app in Privacy settings."
                                       delegate:nil
                              cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
        }
    }
}

@end
