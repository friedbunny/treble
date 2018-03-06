//
//  TRBLTabBarController.m
//  Treble
//
//  Created by Jason Wray on 7/2/17.
//  Copyright © 2017 Mapbox. All rights reserved.
//

#import "TRBLTabBarController.h"

#import "Constants.h"
#import "Additions/UITabBarController+Swipe.h"
#import "Additions/UITabBarController+Index.h"

@interface TRBLTabBarController ()

@end

@implementation TRBLTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];

    // set initial tab to Mapbox
    self.selectedIndex = self.lastSelectedIndex = TRBLMapboxViewControllerIndex;

    // setup swipe transitions
    [self setupSwipeGestureRecognizersAllowCyclingThroughTabs:YES];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self adjustInsetsForNoLabels];
}

- (void)adjustInsetsForNoLabels {
    CGFloat inset;
    UITraitCollection *traits = self.view.traitCollection;

    switch (traits.userInterfaceIdiom) {
        case UIUserInterfaceIdiomPhone:
            if (@available(iOS 11.0, *)) {
                inset = self.view.safeAreaInsets.bottom ? 8 : 5;
            } else {
                inset = 5;
            }
            break;
        case UIUserInterfaceIdiomPad:
        case UIUserInterfaceIdiomTV:
        case UIUserInterfaceIdiomCarPlay:
        case UIUserInterfaceIdiomUnspecified:
            if (@available(iOS 11.0, *)) {
                inset = traits.horizontalSizeClass == UIUserInterfaceSizeClassRegular ? -2 : 5;
            } else {
                inset = 6;
            }
            break;
    }

    for (UITabBarItem *item in self.tabBar.items) {
        item.imageInsets = UIEdgeInsetsMake(inset, 0, -inset, 0);
    }
}

@end
