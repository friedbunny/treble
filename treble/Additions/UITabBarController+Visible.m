//
//  UITabBarController+Visible.m
//  Treble
//
//  Created by Jason Wray on 2/6/17.
//  Copyright © 2017 Mapbox. All rights reserved.
//

#import "UITabBarController+Visible.h"

@implementation UITabBarController (Visible)

- (void)toggleTabBar {
    CGRect frame = self.tabBar.frame;
    CGFloat height = frame.size.height;
    CGFloat offsetY = (self.tabBarIsVisible) ? height : -height;

    self.tabBar.frame = CGRectOffset(frame, 0, offsetY);
}

- (BOOL)tabBarIsVisible {
    return self.tabBar.frame.origin.y < CGRectGetMaxY(self.view.frame);
}

@end
