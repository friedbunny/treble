//
//  UIColor+Treble.m
//  treble
//
//  Created by Jason Wray on 6/6/19.
//  Copyright © 2019 Mapbox. All rights reserved.
//

#import "UIColor+Treble.h"

@implementation UIColor (Treble)

+ (UIColor *)trbl_tintColor {
    if (@available(iOS 11.0, *)) {
        return [UIColor colorNamed:@"Tint"];
    } else {
        return [UIColor colorWithRed:39.f/255.f green:61.f/255.f blue:86.f/255.f alpha:1.f];
    }
}

+ (UIColor *)trbl_primaryTextColor {
    if (@available(iOS 11.0, *)) {
        return [UIColor colorNamed:@"PrimaryText"];
    } else {
        return UIColor.whiteColor;
    }
}

@end
