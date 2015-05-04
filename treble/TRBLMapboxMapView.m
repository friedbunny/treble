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

@interface TRBLMapboxMapView () <MGLMapViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic) IBOutlet MGLMapView *mapView;
@property (nonatomic) UITapGestureRecognizer *tap;
@property (nonatomic) NSString *currentStyle;
@property TRBLCoordinator *coordinator;

@end

@implementation TRBLMapboxMapView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.coordinator = [TRBLCoordinator sharedCoordinator];
    
    self.mapView.accessToken = self.coordinator.mapboxAPIKey;
    self.mapView.showsUserLocation = YES;
    
    self.currentStyle = [[self styles] firstObject];
    
    // setup single tap gesture, which requires failure of double tap
    // currently clobbers double-tap zoom
    //
    UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:nil];
    doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    [self.mapView addGestureRecognizer:doubleTapGestureRecognizer];
    
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    self.tap.delegate = self;
    self.tap.numberOfTapsRequired = 1;
    [self.tap requireGestureRecognizerToFail:doubleTapGestureRecognizer];
    [self.mapView addGestureRecognizer:self.tap];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    self.mapView.centerCoordinate = self.coordinator.region.center;
    self.mapView.zoomLevel = self.coordinator.currentZoom;

    //[self.mapView zoomToSouthWestCoordinate:<#(CLLocationCoordinate2D)#> northEastCoordinate:<#(CLLocationCoordinate2D)#> animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    self.coordinator.currentLocation = self.mapView.centerCoordinate;
    self.coordinator.currentZoom = self.mapView.zoomLevel;
    
    /*CGPoint userLocationPoint = [self convertCoordinate:self.mapView.userLocation.coordinate toPointToView:self];
    CGFloat pixelRadius = fminf(self.mapView.bounds.size.width, self.mapView.bounds.size.height) / 2;
    
    CLLocationCoordinate2D actualSouthWest = [self.mapView convertPoint:CGPointMake(userLocationPoint.x - pixelRadius,
                                                                            userLocationPoint.y - pixelRadius)
                                           toCoordinateFromView:self];
    
    CLLocationCoordinate2D actualNorthEast = [self.mapView convertPoint:CGPointMake(userLocationPoint.x + pixelRadius,
                                                                            userLocationPoint.y + pixelRadius)
                                           toCoordinateFromView:self];*/
    
    //self.coordinator.region = MKCoordinateRegionMakeWithDistance(self.mapView.centerCoordinate, <#CLLocationDistance latitudinalMeters#>, <#CLLocationDistance longitudinalMeters#>);
}

#pragma mark - Gestures -

- (void)handleTapGesture:(id)sender
{
    [self cycleStyles];
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

- (void)locateUser
{
    if (self.mapView.userTrackingMode == MGLUserTrackingModeNone)
    {
        self.mapView.userTrackingMode = MGLUserTrackingModeFollow;
    }
    else if (self.mapView.userTrackingMode == MGLUserTrackingModeFollow)
    {
        self.mapView.userTrackingMode = MGLUserTrackingModeFollowWithHeading;
    }
    else
    {
        self.mapView.userTrackingMode = MGLUserTrackingModeNone;
    }
}

- (void)mapView:(MGLMapView *)mapView didChangeUserTrackingMode:(MGLUserTrackingMode)mode animated:(BOOL)animated
{
    UIImage *newButtonImage;
    
    switch (mode) {
        case MGLUserTrackingModeNone:
            newButtonImage = [UIImage imageNamed:@"TrackingLocationOffMask.png"];
            break;
            
        case MGLUserTrackingModeFollow:
            newButtonImage = [UIImage imageNamed:@"TrackingLocationMask.png"];
            break;
            
        case MGLUserTrackingModeFollowWithHeading:
            newButtonImage = [UIImage imageNamed:@"TrackingHeadingMask.png"];
            break;
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        self.navigationItem.rightBarButtonItem.image = newButtonImage;
    }];
}

@end
