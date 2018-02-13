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

    self.backgroundColor = [self.tintColor colorWithAlphaComponent:0.95];;

    self.titleLabel.font = [UIFont monospacedDigitSystemFontOfSize:9.0 weight:UIFontWeightMedium];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.contentEdgeInsets = UIEdgeInsetsMake(2, 4, 2, 4);

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)];
    [self addGestureRecognizer:tapGesture];
}

- (void)handleTap {
    [self fadeOut];
}

- (void)tintColorDidChange {
    self.backgroundColor = [self.tintColor colorWithAlphaComponent:0.95];;
}

- (void)fadeIn {
    if (self.alpha) {
        return;
    }

    [UIView animateWithDuration:.15 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
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
    if ([NSUserDefaults.standardUserDefaults boolForKey:@"TRBLUIAlwaysShowMapInfoLabel"]) {
        return;
    }

    if (_fadeTimer) {
        [_fadeTimer invalidate];
    }

    _fadeTimer = [NSTimer timerWithTimeInterval:1.5 target:self selector:@selector(fadeOut) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_fadeTimer forMode:NSDefaultRunLoopMode];
}

- (void)update {
    [self setTitle:[NSString stringWithFormat:@"%.2f ∕ %.f°", _zoomLevel, _pitch] forState:UIControlStateNormal];

    [self fadeIn];
    [self startFadeOutTimer];

    [self setNeedsLayout];
}

- (void)reset {
    _zoomLevel = 0;
    _pitch = 0;
}

- (void)didMoveToWindow {
    if (!self.window) {
        [self reset];
    }
}

#pragma mark - Setters

- (void)setZoomLevel:(double)zoomLevel {
    double roundedZoom = round(zoomLevel * 100.f) / 100.f;
    if (_zoomLevel == roundedZoom) {
        return;
    }

    _zoomLevel = roundedZoom;

    [self update];
}

- (void)setPitch:(CGFloat)pitch {
    CGFloat roundedPitch = roundf(pitch * 100.f) / 100.f;
    if (_pitch == roundedPitch) {
        return;
    }

    _pitch = roundedPitch;

    [self update];
}

@end
