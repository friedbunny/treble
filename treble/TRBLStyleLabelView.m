//
//  TRBLStyleLabelView.m
//  Treble
//
//  Created by Jason Wray on 6/27/17.
//  Copyright © 2017 Mapbox. All rights reserved.
//

#import "TRBLStyleLabelView.h"

@interface TRBLStyleLabelView()
@property (nonatomic) NSTimer *fadeTimer;
@end

@implementation TRBLStyleLabelView

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

    self.backgroundColor = [self.tintColor colorWithAlphaComponent:0.95];

    self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.contentEdgeInsets = UIEdgeInsetsMake(3, 6, 3, 6);

    if (@available(iOS 10, *)) {
        self.titleLabel.adjustsFontForContentSizeCategory = YES;
    }

    self.userInteractionEnabled = NO;
}

- (void)tintColorDidChange {
    self.backgroundColor = [self.tintColor colorWithAlphaComponent:0.95];
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

    [UIView animateWithDuration:1.0 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
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

- (void)update {
    NSTimeInterval transitionDuration = self.alpha ? .1 : 0;

    [UIView transitionWithView:self duration:transitionDuration options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [self setTitle:self.styleName forState:UIControlStateNormal];
    } completion:nil];

    [UIView animateWithDuration:transitionDuration delay:0 options:0 animations:^{
        [self layoutIfNeeded];
    } completion:nil];

    [self fadeIn];
    [self startFadeOutTimer];
}

- (void)reset {
    _styleName = nil;
}

- (void)didMoveToWindow {
    if (!self.window) {
        [self reset];
    }
}

#pragma mark - Setters

- (void)setStyleName:(NSString *)styleName {
    _styleName = styleName;

    [self update];
}

@end
