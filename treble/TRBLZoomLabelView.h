//
//  TRBLZoomLabelView.h
//  Treble
//
//  Created by Jason Wray on 2/10/17.
//  Copyright © 2017 Mapbox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TRBLZoomLabelView : UILabel

@property (nonatomic) double zoomLevel;

- (void)fadeIn;
- (void)fadeOut;

@end
