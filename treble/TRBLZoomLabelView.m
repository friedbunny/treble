//
//  TRBLZoomLabelView.m
//  Treble
//
//  Created by Jason Wray on 2/10/17.
//  Copyright © 2017 Mapbox. All rights reserved.
//

#import "TRBLZoomLabelView.h"

@interface TRBLZoomLabelView()
@property (nonatomic) NSTimer *fadeTimer;
@end

@implementation TRBLZoomLabelView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.alpha = 0;
    self.layer.cornerRadius = 2.0;
    self.layer.masksToBounds = YES;

    self.backgroundColor = self.tintColor;

    self.font = [UIFont monospacedDigitSystemFontOfSize:9.0 weight:UIFontWeightMedium];
    self.textColor = [UIColor whiteColor];
    self.textAlignment = NSTextAlignmentCenter;

    self.userInteractionEnabled = NO;
}

- (void)tintColorDidChange {
    self.backgroundColor = self.tintColor;
}

- (void)fadeIn {
    if (self.alpha) {
        return;
    }

    [UIView animateWithDuration:.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.alpha = 1.0;
    } completion:nil];
}

- (void)fadeOut {
    if (!self.alpha) {
        return;
    }

    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.alpha = 0.0;
    } completion:nil];
}

- (void)startFadeOutTimer {
    if (_fadeTimer) {
        [_fadeTimer invalidate];
    }

    _fadeTimer = [NSTimer timerWithTimeInterval:1.5 target:self selector:@selector(fadeOut) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_fadeTimer forMode:NSDefaultRunLoopMode];
}

#pragma mark - Setters

- (void)setZoomLevel:(double)zoomLevel {
    double roundedZoom = roundf(zoomLevel * 100.f) / 100.f;
    if (_zoomLevel == roundedZoom) {
        return;
    }

    _zoomLevel = roundedZoom;
    self.text = [NSString stringWithFormat:@"%.2f", roundedZoom];

    [self fadeIn];
    [self startFadeOutTimer];

    [self setNeedsLayout];
}

@end
