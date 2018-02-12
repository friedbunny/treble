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

    [self truncateTabBarHeight];
    [self hideTarBarItemText];
}

- (void)truncateTabBarHeight {
    CGFloat newHeight = 45;

    if (@available(iOS 11.0, *)) {
        if (self.view.safeAreaInsets.bottom) {
            newHeight += 15;
        }
    }

    CGRect newFrame = self.tabBar.frame;

    newFrame.size.height = newHeight;
    newFrame.origin.y = self.view.frame.size.height - newHeight;


    self.tabBar.frame = newFrame;
}

- (void)hideTarBarItemText {
    CGFloat inset;

    switch (UIDevice.currentDevice.userInterfaceIdiom) {
        case UIUserInterfaceIdiomPhone:
            inset = 5;
            break;
        case UIUserInterfaceIdiomPad:
        case UIUserInterfaceIdiomTV:
        case UIUserInterfaceIdiomCarPlay:
        case UIUserInterfaceIdiomUnspecified:
            inset = 7;
            break;
    }

    if (@available(iOS 11.0, *)) {
        if (self.view.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular) {
            inset = 0;
        } else if (self.view.safeAreaInsets.bottom) {
            inset += 6;
        }
    }

    for (UITabBarItem *item in self.tabBar.items) {
        item.imageInsets = UIEdgeInsetsMake(inset, 0, -inset, 0);
    }
}

@end
