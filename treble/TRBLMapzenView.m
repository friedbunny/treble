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

@interface TRBLMapzenView () <TGMapViewDelegate, TGRecognizerDelegate, TRBLCoordinatorDelegate>

@property TRBLCoordinator *coordinator;
@property (nonatomic) BOOL shouldUpdateCoordinates;
@property (nonatomic) IBOutlet TRBLZoomLabelView *zoomLabelView;

@property (nonatomic) TGSceneUpdate *apiKey;

@end

@implementation TRBLMapzenView

- (void)viewDidLoad {
    [super viewDidLoad];

    self.coordinator = [TRBLCoordinator sharedCoordinator];

    self.mapViewDelegate = self;
    self.gestureDelegate = self;
    self.coordinator.delegate = self;

//    NSDictionary *apiKeys = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"APIKeys" ofType:@"plist"]];
//    NSString *mapzenAPIKey = [apiKeys objectForKey:@"Mapzen API Key"];
//    self.apiKey = [[TGSceneUpdate alloc] initWithPath:@"global.sdk_mapzen_api_key" value:[NSString stringWithFormat:@"{ api_key: %@ }", mapzenAPIKey]];
}

- (void)viewWillAppear:(BOOL)animated {
    //[super loadSceneFileAsync:@"https://tangrams.github.io/walkabout-style/walkabout-style.yaml"];
    //sceneUpdates:@[self.apiKey]
}

- (void)mapShouldChangeStyle {

}

- (void)mapView:(TGMapViewController *)mapView didLoadSceneAsync:(NSString *)scene {
    NSLog(@"Did load scene async %@", scene);

    TGGeoPoint newYork;
    newYork.longitude = -74.00976419448854;
    newYork.latitude = 40.70532700869127;

    TGGeoPoint cairo;
    cairo.longitude = 30.00;
    cairo.latitude = 31.25;

    [mapView setZoom:15];
    [mapView setPosition:newYork];
}

@end
