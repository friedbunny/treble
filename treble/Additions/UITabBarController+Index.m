//
//  UITabBarController+Index.m
//  Treble
//
//  Created by Jason Wray on 5/16/15.
//  Copyright (c) 2015 Mapbox. All rights reserved.
//

#import "UITabBarController+Index.h"

#import "TRBLCoordinator.h"

@implementation UITabBarController (Index)

@dynamic lastSelectedIndex;

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    NSUInteger selectedIndex = [[tabBar items] indexOfObject:item];
    
    if (selectedIndex == self.lastSelectedIndex || ! self.lastSelectedIndex)
    {
        [[TRBLCoordinator sharedCoordinator].delegate mapShouldChangeStyle];
    }
    
    self.lastSelectedIndex = selectedIndex;
}

- (void)setLastSelectedIndex:(NSUInteger)lastSelectedIndex
{
    objc_setAssociatedObject(self, @selector(lastSelectedIndex), [NSNumber numberWithLong:lastSelectedIndex], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSUInteger)lastSelectedIndex {
    return [objc_getAssociatedObject(self, @selector(lastSelectedIndex)) longValue];
}

@end
