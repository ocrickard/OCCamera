//
//  OCCameraViewController.m
//  OCCamera
//
//  Created by Oliver Rickard on 02/02/2013.
//  Copyright (c) 2013 Oliver Rickard. All rights reserved.
//

#import "OCCameraViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "DIYAVUtilities.h"

#define kIconFill [UIColor whiteColor]
#define kBottomBarFill [UIColor whiteColor]
#define kCameraButtonFill [UIColor colorWithWhite:0.104 alpha:1.000]
#define kCameraButtonHighlightedFill [UIColor colorWithWhite:0.25 alpha:1.000]
#define kCameraButtonRecordingFill [UIColor redColor]


#pragma mark - Accessory Views

typedef enum {
    OCCameraSwitchModePicture,
    OCCameraSwitchModeVideo
} OCCameraSwitchMode;

@protocol OCCameraSwitchDelegate <NSObject>

- (void)cameraSwitchChangedModes:(OCCameraSwitchMode)mode;

@end

@interface OCCameraSwitch : UIView {
    CALayer *slider;
    CGRect switchFrame;
    CGRect sliderTrackFrame;
    
    OCCameraSwitchMode mode;
    
    __weak id<OCCameraSwitchDelegate> delegate;
}

@property (nonatomic, assign) OCCameraSwitchMode mode;
@property (nonatomic, weak) id<OCCameraSwitchDelegate> delegate;

@end

@implementation OCCameraSwitch
@synthesize mode;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if(self) {
        self.backgroundColor = [UIColor clearColor];
        self.mode = OCCameraSwitchModePicture;
        
        switchFrame = CGRectMake(floorf(self.bounds.size.width*0.5f - 80.f*0.5f), floorf(self.bounds.size.height*0.5f - 28.f*0.5f), 80.f, 28.f);
        sliderTrackFrame = CGRectMake(CGRectGetMinX(switchFrame) + 16, CGRectGetMinY(switchFrame) + 5, 47, 18);
        
        slider = [CALayer layer];
        slider.frame = CGRectMake(CGRectGetMinX(switchFrame) + 19, CGRectGetMinY(switchFrame) + 8, 16, 12);
        slider.cornerRadius = 4.f;
        slider.masksToBounds = YES;
        slider.backgroundColor = kCameraButtonFill.CGColor;
        [self.layer addSublayer:slider];
        
        self.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [self addGestureRecognizer:tap];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [self addGestureRecognizer:pan];
    }
    
    return self;
}

- (void)setMode:(OCCameraSwitchMode)m {
    if(m != mode) {
        mode = m;
        if([delegate respondsToSelector:@selector(cameraSwitchChangedModes:)]) {
            [delegate cameraSwitchChangedModes:mode];
        }
    }
}

- (void)handleTap:(UITapGestureRecognizer *)tap {
    if(self.mode == OCCameraSwitchModePicture) {
        self.mode = OCCameraSwitchModeVideo;
        slider.frame = CGRectMake(CGRectGetMaxX(sliderTrackFrame) - 19, CGRectGetMinY(switchFrame) + 8, 16, 12);
    } else {
        self.mode = OCCameraSwitchModePicture;
        slider.frame = CGRectMake(CGRectGetMinX(sliderTrackFrame) + 3, CGRectGetMinY(switchFrame) + 8, 16, 12);
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)pan {
    if(pan.state == UIGestureRecognizerStateBegan) {
        
    } else if(pan.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [pan translationInView:self];
        [pan setTranslation:CGPointZero inView:self];
        
        CGFloat newX = slider.frame.origin.x + translation.x;
        
        if(newX > CGRectGetMaxX(sliderTrackFrame) - 19) {
            newX = CGRectGetMaxX(sliderTrackFrame) - 19;
        } else if(newX < CGRectGetMinX(sliderTrackFrame) + 3) {
            newX = CGRectGetMinX(sliderTrackFrame) + 3;
        }
        
        slider.frame = CGRectMake(newX, slider.frame.origin.y, slider.frame.size.width, slider.frame.size.height);
    } else if(pan.state == UIGestureRecognizerStateEnded) {
        CGPoint translation = [pan translationInView:self];
        
        CGFloat newX = slider.frame.origin.x + translation.x;
        
        if(newX > CGRectGetMaxX(sliderTrackFrame) - 19) {
            newX = CGRectGetMaxX(sliderTrackFrame) - 19;
        } else if(newX < CGRectGetMinX(sliderTrackFrame) + 3) {
            newX = CGRectGetMinX(sliderTrackFrame) + 3;
        }
        
        CGFloat halfWay = ((CGRectGetMaxX(sliderTrackFrame) - 19) - (CGRectGetMinX(sliderTrackFrame) + 3)) * 0.5f + (CGRectGetMinX(sliderTrackFrame) + 3) ;
        
        if(newX > halfWay) {
            self.mode = OCCameraSwitchModeVideo;
            slider.frame = CGRectMake(CGRectGetMaxX(sliderTrackFrame) - 19, slider.frame.origin.y, slider.frame.size.width, slider.frame.size.height);
        } else {
            self.mode = OCCameraSwitchModePicture;
            slider.frame = CGRectMake(CGRectGetMinX(sliderTrackFrame) + 3, slider.frame.origin.y, slider.frame.size.width, slider.frame.size.height);
        }
    }
}

- (void)drawRect:(CGRect)rect {
    //// Color Declarations
    UIColor* trackColor = [UIColor colorWithRed: 0.921 green: 0.921 blue: 0.921 alpha: 1];
    
    //// switchTrack Drawing
    UIBezierPath* switchTrackPath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(CGRectGetMinX(switchFrame) + 16, CGRectGetMinY(switchFrame) + 5, 47, 18) cornerRadius: 4];
    [trackColor setFill];
    [switchTrackPath fill];
    
    
    //// switchCamera Drawing
    UIBezierPath* switchCameraPath = [UIBezierPath bezierPath];
    [switchCameraPath moveToPoint: CGPointMake(CGRectGetMinX(switchFrame) + 8.46, CGRectGetMinY(switchFrame) + 15.93)];
    [switchCameraPath addCurveToPoint: CGPointMake(CGRectGetMinX(switchFrame) + 8.46, CGRectGetMinY(switchFrame) + 12.89) controlPoint1: CGPointMake(CGRectGetMinX(switchFrame) + 9.26, CGRectGetMinY(switchFrame) + 15.09) controlPoint2: CGPointMake(CGRectGetMinX(switchFrame) + 9.26, CGRectGetMinY(switchFrame) + 13.73)];
    [switchCameraPath addCurveToPoint: CGPointMake(CGRectGetMinX(switchFrame) + 5.54, CGRectGetMinY(switchFrame) + 12.89) controlPoint1: CGPointMake(CGRectGetMinX(switchFrame) + 7.65, CGRectGetMinY(switchFrame) + 12.05) controlPoint2: CGPointMake(CGRectGetMinX(switchFrame) + 6.35, CGRectGetMinY(switchFrame) + 12.05)];
    [switchCameraPath addCurveToPoint: CGPointMake(CGRectGetMinX(switchFrame) + 5.54, CGRectGetMinY(switchFrame) + 15.93) controlPoint1: CGPointMake(CGRectGetMinX(switchFrame) + 4.74, CGRectGetMinY(switchFrame) + 13.73) controlPoint2: CGPointMake(CGRectGetMinX(switchFrame) + 4.74, CGRectGetMinY(switchFrame) + 15.09)];
    [switchCameraPath addCurveToPoint: CGPointMake(CGRectGetMinX(switchFrame) + 8.46, CGRectGetMinY(switchFrame) + 15.93) controlPoint1: CGPointMake(CGRectGetMinX(switchFrame) + 6.35, CGRectGetMinY(switchFrame) + 16.77) controlPoint2: CGPointMake(CGRectGetMinX(switchFrame) + 7.65, CGRectGetMinY(switchFrame) + 16.77)];
    [switchCameraPath closePath];
    [switchCameraPath moveToPoint: CGPointMake(CGRectGetMinX(switchFrame) + 8.47, CGRectGetMinY(switchFrame) + 10)];
    [switchCameraPath addCurveToPoint: CGPointMake(CGRectGetMinX(switchFrame) + 9.25, CGRectGetMinY(switchFrame) + 11.23) controlPoint1: CGPointMake(CGRectGetMinX(switchFrame) + 8.47, CGRectGetMinY(switchFrame) + 10) controlPoint2: CGPointMake(CGRectGetMinX(switchFrame) + 9.25, CGRectGetMinY(switchFrame) + 10.13)];
    [switchCameraPath addCurveToPoint: CGPointMake(CGRectGetMinX(switchFrame) + 11.21, CGRectGetMinY(switchFrame) + 11.23) controlPoint1: CGPointMake(CGRectGetMinX(switchFrame) + 9.62, CGRectGetMinY(switchFrame) + 11.24) controlPoint2: CGPointMake(CGRectGetMinX(switchFrame) + 10.6, CGRectGetMinY(switchFrame) + 11.23)];
    [switchCameraPath addCurveToPoint: CGPointMake(CGRectGetMinX(switchFrame) + 12, CGRectGetMinY(switchFrame) + 12.26) controlPoint1: CGPointMake(CGRectGetMinX(switchFrame) + 12.06, CGRectGetMinY(switchFrame) + 11.23) controlPoint2: CGPointMake(CGRectGetMinX(switchFrame) + 12, CGRectGetMinY(switchFrame) + 12.26)];
    [switchCameraPath addCurveToPoint: CGPointMake(CGRectGetMinX(switchFrame) + 12, CGRectGetMinY(switchFrame) + 16.97) controlPoint1: CGPointMake(CGRectGetMinX(switchFrame) + 12, CGRectGetMinY(switchFrame) + 12.26) controlPoint2: CGPointMake(CGRectGetMinX(switchFrame) + 11.99, CGRectGetMinY(switchFrame) + 16.53)];
    [switchCameraPath addCurveToPoint: CGPointMake(CGRectGetMinX(switchFrame) + 11.02, CGRectGetMinY(switchFrame) + 18) controlPoint1: CGPointMake(CGRectGetMinX(switchFrame) + 12, CGRectGetMinY(switchFrame) + 18.05) controlPoint2: CGPointMake(CGRectGetMinX(switchFrame) + 11.02, CGRectGetMinY(switchFrame) + 18)];
    [switchCameraPath addCurveToPoint: CGPointMake(CGRectGetMinX(switchFrame) + 2.98, CGRectGetMinY(switchFrame) + 18) controlPoint1: CGPointMake(CGRectGetMinX(switchFrame) + 11.02, CGRectGetMinY(switchFrame) + 18) controlPoint2: CGPointMake(CGRectGetMinX(switchFrame) + 3.5, CGRectGetMinY(switchFrame) + 18)];
    [switchCameraPath addCurveToPoint: CGPointMake(CGRectGetMinX(switchFrame) + 2, CGRectGetMinY(switchFrame) + 16.77) controlPoint1: CGPointMake(CGRectGetMinX(switchFrame) + 1.97, CGRectGetMinY(switchFrame) + 17.97) controlPoint2: CGPointMake(CGRectGetMinX(switchFrame) + 2, CGRectGetMinY(switchFrame) + 16.77)];
    [switchCameraPath addCurveToPoint: CGPointMake(CGRectGetMinX(switchFrame) + 2, CGRectGetMinY(switchFrame) + 12.26) controlPoint1: CGPointMake(CGRectGetMinX(switchFrame) + 2, CGRectGetMinY(switchFrame) + 16.77) controlPoint2: CGPointMake(CGRectGetMinX(switchFrame) + 2, CGRectGetMinY(switchFrame) + 12.63)];
    [switchCameraPath addCurveToPoint: CGPointMake(CGRectGetMinX(switchFrame) + 2.78, CGRectGetMinY(switchFrame) + 11.23) controlPoint1: CGPointMake(CGRectGetMinX(switchFrame) + 2.01, CGRectGetMinY(switchFrame) + 11.22) controlPoint2: CGPointMake(CGRectGetMinX(switchFrame) + 2.78, CGRectGetMinY(switchFrame) + 11.23)];
    [switchCameraPath addCurveToPoint: CGPointMake(CGRectGetMinX(switchFrame) + 4.75, CGRectGetMinY(switchFrame) + 11.23) controlPoint1: CGPointMake(CGRectGetMinX(switchFrame) + 2.78, CGRectGetMinY(switchFrame) + 11.23) controlPoint2: CGPointMake(CGRectGetMinX(switchFrame) + 4.51, CGRectGetMinY(switchFrame) + 11.23)];
    [switchCameraPath addCurveToPoint: CGPointMake(CGRectGetMinX(switchFrame) + 5.73, CGRectGetMinY(switchFrame) + 10) controlPoint1: CGPointMake(CGRectGetMinX(switchFrame) + 4.84, CGRectGetMinY(switchFrame) + 10.08) controlPoint2: CGPointMake(CGRectGetMinX(switchFrame) + 5.73, CGRectGetMinY(switchFrame) + 10)];
    [switchCameraPath addLineToPoint: CGPointMake(CGRectGetMinX(switchFrame) + 8.47, CGRectGetMinY(switchFrame) + 10)];
    [switchCameraPath closePath];
    [switchCameraPath moveToPoint: CGPointMake(CGRectGetMinX(switchFrame) + 5.13, CGRectGetMinY(switchFrame) + 12.45)];
    [switchCameraPath addCurveToPoint: CGPointMake(CGRectGetMinX(switchFrame) + 5.13, CGRectGetMinY(switchFrame) + 16.37) controlPoint1: CGPointMake(CGRectGetMinX(switchFrame) + 4.09, CGRectGetMinY(switchFrame) + 13.53) controlPoint2: CGPointMake(CGRectGetMinX(switchFrame) + 4.09, CGRectGetMinY(switchFrame) + 15.29)];
    [switchCameraPath addCurveToPoint: CGPointMake(CGRectGetMinX(switchFrame) + 8.87, CGRectGetMinY(switchFrame) + 16.37) controlPoint1: CGPointMake(CGRectGetMinX(switchFrame) + 6.16, CGRectGetMinY(switchFrame) + 17.45) controlPoint2: CGPointMake(CGRectGetMinX(switchFrame) + 7.84, CGRectGetMinY(switchFrame) + 17.45)];
    [switchCameraPath addCurveToPoint: CGPointMake(CGRectGetMinX(switchFrame) + 8.87, CGRectGetMinY(switchFrame) + 12.45) controlPoint1: CGPointMake(CGRectGetMinX(switchFrame) + 9.9, CGRectGetMinY(switchFrame) + 15.29) controlPoint2: CGPointMake(CGRectGetMinX(switchFrame) + 9.9, CGRectGetMinY(switchFrame) + 13.53)];
    [switchCameraPath addCurveToPoint: CGPointMake(CGRectGetMinX(switchFrame) + 5.13, CGRectGetMinY(switchFrame) + 12.45) controlPoint1: CGPointMake(CGRectGetMinX(switchFrame) + 7.84, CGRectGetMinY(switchFrame) + 11.37) controlPoint2: CGPointMake(CGRectGetMinX(switchFrame) + 6.16, CGRectGetMinY(switchFrame) + 11.37)];
    [switchCameraPath closePath];
    [kCameraButtonFill setFill];
    [switchCameraPath fill];
    
    
    //// switchFilmCamera Drawing
    UIBezierPath* switchFilmCameraPath = [UIBezierPath bezierPath];
    [switchFilmCameraPath moveToPoint: CGPointMake(CGRectGetMinX(switchFrame) + 77.5, CGRectGetMinY(switchFrame) + 16.5)];
    [switchFilmCameraPath addLineToPoint: CGPointMake(CGRectGetMinX(switchFrame) + 74.5, CGRectGetMinY(switchFrame) + 14.25)];
    [switchFilmCameraPath addLineToPoint: CGPointMake(CGRectGetMinX(switchFrame) + 74.5, CGRectGetMinY(switchFrame) + 14.5)];
    [switchFilmCameraPath addCurveToPoint: CGPointMake(CGRectGetMinX(switchFrame) + 72.5, CGRectGetMinY(switchFrame) + 16.5) controlPoint1: CGPointMake(CGRectGetMinX(switchFrame) + 74.5, CGRectGetMinY(switchFrame) + 15.6) controlPoint2: CGPointMake(CGRectGetMinX(switchFrame) + 73.6, CGRectGetMinY(switchFrame) + 16.5)];
    [switchFilmCameraPath addLineToPoint: CGPointMake(CGRectGetMinX(switchFrame) + 67.5, CGRectGetMinY(switchFrame) + 16.5)];
    [switchFilmCameraPath addCurveToPoint: CGPointMake(CGRectGetMinX(switchFrame) + 65.5, CGRectGetMinY(switchFrame) + 14.5) controlPoint1: CGPointMake(CGRectGetMinX(switchFrame) + 66.4, CGRectGetMinY(switchFrame) + 16.5) controlPoint2: CGPointMake(CGRectGetMinX(switchFrame) + 65.5, CGRectGetMinY(switchFrame) + 15.6)];
    [switchFilmCameraPath addLineToPoint: CGPointMake(CGRectGetMinX(switchFrame) + 65.5, CGRectGetMinY(switchFrame) + 12.5)];
    [switchFilmCameraPath addCurveToPoint: CGPointMake(CGRectGetMinX(switchFrame) + 67.5, CGRectGetMinY(switchFrame) + 10.5) controlPoint1: CGPointMake(CGRectGetMinX(switchFrame) + 65.5, CGRectGetMinY(switchFrame) + 11.4) controlPoint2: CGPointMake(CGRectGetMinX(switchFrame) + 66.4, CGRectGetMinY(switchFrame) + 10.5)];
    [switchFilmCameraPath addLineToPoint: CGPointMake(CGRectGetMinX(switchFrame) + 72.5, CGRectGetMinY(switchFrame) + 10.5)];
    [switchFilmCameraPath addCurveToPoint: CGPointMake(CGRectGetMinX(switchFrame) + 74.5, CGRectGetMinY(switchFrame) + 12.5) controlPoint1: CGPointMake(CGRectGetMinX(switchFrame) + 73.6, CGRectGetMinY(switchFrame) + 10.5) controlPoint2: CGPointMake(CGRectGetMinX(switchFrame) + 74.5, CGRectGetMinY(switchFrame) + 11.4)];
    [switchFilmCameraPath addLineToPoint: CGPointMake(CGRectGetMinX(switchFrame) + 74.5, CGRectGetMinY(switchFrame) + 12.75)];
    [switchFilmCameraPath addLineToPoint: CGPointMake(CGRectGetMinX(switchFrame) + 77.5, CGRectGetMinY(switchFrame) + 10.5)];
    [switchFilmCameraPath addLineToPoint: CGPointMake(CGRectGetMinX(switchFrame) + 77.5, CGRectGetMinY(switchFrame) + 16.5)];
    [switchFilmCameraPath closePath];
    [kCameraButtonFill setFill];
    [switchFilmCameraPath fill];
    
    
}

@end

@interface OCCameraButton : UIButton {
    BOOL recording;
}

- (void)setRecording:(BOOL)recording;

@end

@implementation OCCameraButton

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if(self) {
        self.backgroundColor = [UIColor clearColor];
        recording = NO;
    }
    
    return self;
}

- (void)setRecording:(BOOL)r {
    if(r != recording) {
        recording = r;
        [self setNeedsDisplay];
    }
}

- (void)setHighlighted:(BOOL)highlighted {
    BOOL oldHighlighted = self.highlighted;
    
    [super setHighlighted:highlighted];
    
    if(highlighted != oldHighlighted) {
        [self setNeedsDisplay];
    }
}

- (void)drawRect:(CGRect)rect {
    
    //// Frames
    CGRect frame = CGRectMake(floorf(self.bounds.size.width*0.5f - 60.f*0.5f), floorf(self.bounds.size.height*0.5f - 67.f*0.5f), 60.f, 67.f);
    
    
    //// Polygon Drawing
    UIBezierPath* polygonPath = [UIBezierPath bezierPath];
    [polygonPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 30, CGRectGetMinY(frame) + 3)];
    [polygonPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 4.02, CGRectGetMinY(frame) + 18)];
    [polygonPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 4.02, CGRectGetMinY(frame) + 48)];
    [polygonPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 30, CGRectGetMinY(frame) + 63)];
    [polygonPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 55.98, CGRectGetMinY(frame) + 48)];
    [polygonPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 55.98, CGRectGetMinY(frame) + 18)];
    [polygonPath closePath];
    
    if(recording) {
        [kCameraButtonRecordingFill setFill];
    } else {
        if(self.highlighted) {
            [kCameraButtonHighlightedFill setFill];
        } else {
            [kCameraButtonFill setFill];
        }
    }
    
    [polygonPath fill];
    [[UIColor whiteColor] setStroke];
    polygonPath.lineWidth = 4;
    [polygonPath stroke];
    
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 33.14, CGRectGetMinY(frame) + 36.83)];
    [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 33.14, CGRectGetMinY(frame) + 29.22) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 35.15, CGRectGetMinY(frame) + 34.73) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 35.15, CGRectGetMinY(frame) + 31.32)];
    [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 25.86, CGRectGetMinY(frame) + 29.22) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 31.13, CGRectGetMinY(frame) + 27.12) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 27.87, CGRectGetMinY(frame) + 27.12)];
    [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 25.86, CGRectGetMinY(frame) + 36.83) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 23.85, CGRectGetMinY(frame) + 31.32) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 23.85, CGRectGetMinY(frame) + 34.73)];
    [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 33.14, CGRectGetMinY(frame) + 36.83) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 27.87, CGRectGetMinY(frame) + 38.94) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 31.13, CGRectGetMinY(frame) + 38.94)];
    [bezierPath closePath];
    [bezierPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 33.18, CGRectGetMinY(frame) + 22)];
    [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 35.14, CGRectGetMinY(frame) + 25.08) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 33.18, CGRectGetMinY(frame) + 22) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 35.13, CGRectGetMinY(frame) + 22.33)];
    [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 40.04, CGRectGetMinY(frame) + 25.08) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 36.05, CGRectGetMinY(frame) + 25.1) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 38.49, CGRectGetMinY(frame) + 25.08)];
    [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 42, CGRectGetMinY(frame) + 27.64) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 42.16, CGRectGetMinY(frame) + 25.07) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 42, CGRectGetMinY(frame) + 27.64)];
    [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 42, CGRectGetMinY(frame) + 39.44) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 42, CGRectGetMinY(frame) + 27.64) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 41.97, CGRectGetMinY(frame) + 38.33)];
    [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 39.55, CGRectGetMinY(frame) + 42) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 41.99, CGRectGetMinY(frame) + 42.13) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 39.55, CGRectGetMinY(frame) + 42)];
    [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 19.45, CGRectGetMinY(frame) + 42) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 39.55, CGRectGetMinY(frame) + 42) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 20.76, CGRectGetMinY(frame) + 42)];
    [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 17, CGRectGetMinY(frame) + 38.92) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 16.92, CGRectGetMinY(frame) + 41.93) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 17, CGRectGetMinY(frame) + 38.92)];
    [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 17, CGRectGetMinY(frame) + 27.64) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 17, CGRectGetMinY(frame) + 38.92) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 17, CGRectGetMinY(frame) + 28.59)];
    [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 18.96, CGRectGetMinY(frame) + 25.08) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 17.03, CGRectGetMinY(frame) + 25.04) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 18.96, CGRectGetMinY(frame) + 25.08)];
    [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 23.86, CGRectGetMinY(frame) + 25.08) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 18.96, CGRectGetMinY(frame) + 25.08) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 23.28, CGRectGetMinY(frame) + 25.08)];
    [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 26.31, CGRectGetMinY(frame) + 22) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 24.09, CGRectGetMinY(frame) + 22.2) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 26.31, CGRectGetMinY(frame) + 22)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 33.18, CGRectGetMinY(frame) + 22)];
    [bezierPath closePath];
    [bezierPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 24.82, CGRectGetMinY(frame) + 28.13)];
    [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 24.82, CGRectGetMinY(frame) + 37.92) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 22.24, CGRectGetMinY(frame) + 30.83) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 22.24, CGRectGetMinY(frame) + 35.22)];
    [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 34.18, CGRectGetMinY(frame) + 37.92) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 27.4, CGRectGetMinY(frame) + 40.62) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 31.59, CGRectGetMinY(frame) + 40.62)];
    [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 34.18, CGRectGetMinY(frame) + 28.13) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 36.76, CGRectGetMinY(frame) + 35.22) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 36.76, CGRectGetMinY(frame) + 30.83)];
    [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 24.82, CGRectGetMinY(frame) + 28.13) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 31.59, CGRectGetMinY(frame) + 25.43) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 27.4, CGRectGetMinY(frame) + 25.43)];
    [bezierPath closePath];
    [[UIColor whiteColor] setFill];
    [bezierPath fill];

}

@end

@interface OCCameraFlashIcon : UIView

typedef enum {
    OCCameraFlashIconModeOn,
    OCCameraFlashIconModeOff,
    OCCameraFlashIconModeAuto
} OCCameraFlashIconMode;

@property (nonatomic, assign) OCCameraFlashIconMode mode;

@end

@implementation OCCameraFlashIcon

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if(self) {
        self.backgroundColor = [UIColor clearColor];
        self.layer.shouldRasterize = YES;
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    if(self.mode == OCCameraFlashIconModeOn) {
        
        //// flashOn Drawing
        CGRect frame = CGRectMake(self.bounds.size.width*0.5f - 8.f*0.5f, self.bounds.size.height*0.5f - 17.f*0.5f, 8.f, 17.f);
        
        
        //// flashOn Drawing
        UIBezierPath* flashOnPath = [UIBezierPath bezierPath];
        [flashOnPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 2.82, CGRectGetMinY(frame))];
        [flashOnPath addLineToPoint: CGPointMake(CGRectGetMinX(frame), CGRectGetMinY(frame) + 8.26)];
        [flashOnPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 4.71, CGRectGetMinY(frame) + 8.26)];
        [flashOnPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 3.29, CGRectGetMinY(frame) + 12.63)];
        [flashOnPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.94, CGRectGetMinY(frame) + 12.63)];
        [flashOnPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 3.76, CGRectGetMinY(frame) + 17)];
        [flashOnPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 8, CGRectGetMinY(frame) + 12.63)];
        [flashOnPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 5.65, CGRectGetMinY(frame) + 12.63)];
        [flashOnPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 8, CGRectGetMinY(frame) + 6.31)];
        [flashOnPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 3.29, CGRectGetMinY(frame) + 6.31)];
        [flashOnPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 5.18, CGRectGetMinY(frame))];
        [flashOnPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 2.82, CGRectGetMinY(frame))];
        [flashOnPath closePath];
        [kIconFill setFill];
        [flashOnPath fill];
        
        
            
    } else if(self.mode == OCCameraFlashIconModeOff) {
        
        //// flashOff Drawing
        // Circle/lightning with a line through it
        CGRect frame = CGRectMake(self.bounds.size.width*0.5f - 22.f*0.5f, self.bounds.size.height*0.5f - 21.f*0.5f, 22.f, 21.f);
        
        
        //// flashOff Drawing
        UIBezierPath* flashOffPath = [UIBezierPath bezierPath];
        [flashOffPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 11.73, CGRectGetMinY(frame) + 1.98)];
        [flashOffPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 9.95, CGRectGetMinY(frame) + 7.5)];
        [flashOffPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 15.19, CGRectGetMinY(frame) + 7.5)];
        [flashOffPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 12.57, CGRectGetMinY(frame) + 14)];
        [flashOffPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 15.19, CGRectGetMinY(frame) + 14)];
        [flashOffPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 10.48, CGRectGetMinY(frame) + 18.5)];
        [flashOffPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 7.33, CGRectGetMinY(frame) + 14)];
        [flashOffPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 9.95, CGRectGetMinY(frame) + 14)];
        [flashOffPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 11.52, CGRectGetMinY(frame) + 9.5)];
        [flashOffPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 6.29, CGRectGetMinY(frame) + 9.5)];
        [flashOffPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 9, CGRectGetMinY(frame) + 2.17)];
        [flashOffPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 4.67, CGRectGetMinY(frame) + 4.46) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 7.41, CGRectGetMinY(frame) + 2.52) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 5.9, CGRectGetMinY(frame) + 3.28)];
        [flashOffPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 6.5, CGRectGetMinY(frame) + 6.23) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 4.81, CGRectGetMinY(frame) + 4.57) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 6.5, CGRectGetMinY(frame) + 6.23)];
        [flashOffPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 5.86, CGRectGetMinY(frame) + 6.79)];
        [flashOffPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 4.08, CGRectGetMinY(frame) + 5.08) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 5.86, CGRectGetMinY(frame) + 6.79) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 4.18, CGRectGetMinY(frame) + 5.18)];
        [flashOffPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 3.24, CGRectGetMinY(frame) + 6.23) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 3.76, CGRectGetMinY(frame) + 5.44) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 3.49, CGRectGetMinY(frame) + 5.83)];
        [flashOffPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 4.67, CGRectGetMinY(frame) + 16.54) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 1.26, CGRectGetMinY(frame) + 9.49) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 1.74, CGRectGetMinY(frame) + 13.75)];
        [flashOffPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 16.71, CGRectGetMinY(frame) + 17.07) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 7.92, CGRectGetMinY(frame) + 19.65) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 13.19, CGRectGetMinY(frame) + 19.75)];
        [flashOffPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 15.08, CGRectGetMinY(frame) + 15.45) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 16.51, CGRectGetMinY(frame) + 16.83) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 15.08, CGRectGetMinY(frame) + 15.45)];
        [flashOffPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 15.68, CGRectGetMinY(frame) + 14.83)];
        [flashOffPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 17.33, CGRectGetMinY(frame) + 16.54) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 15.68, CGRectGetMinY(frame) + 14.83) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 17.16, CGRectGetMinY(frame) + 16.39)];
        [flashOffPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 18.46, CGRectGetMinY(frame) + 15.23) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 17.76, CGRectGetMinY(frame) + 16.13) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 18.13, CGRectGetMinY(frame) + 15.7)];
        [flashOffPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 17.33, CGRectGetMinY(frame) + 4.46) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 20.78, CGRectGetMinY(frame) + 11.91) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 20.4, CGRectGetMinY(frame) + 7.39)];
        [flashOffPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 11.73, CGRectGetMinY(frame) + 1.98) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 15.77, CGRectGetMinY(frame) + 2.97) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 13.77, CGRectGetMinY(frame) + 2.14)];
        [flashOffPath closePath];
        [flashOffPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 18.78, CGRectGetMinY(frame) + 3.08)];
        [flashOffPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 19.98, CGRectGetMinY(frame) + 16.57) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 22.63, CGRectGetMinY(frame) + 6.75) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 23.03, CGRectGetMinY(frame) + 12.47)];
        [flashOffPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 18.78, CGRectGetMinY(frame) + 17.92) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 19.62, CGRectGetMinY(frame) + 17.04) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 19.22, CGRectGetMinY(frame) + 17.5)];
        [flashOffPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 3.22, CGRectGetMinY(frame) + 17.92) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 14.48, CGRectGetMinY(frame) + 22.03) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 7.52, CGRectGetMinY(frame) + 22.03)];
        [flashOffPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 1.64, CGRectGetMinY(frame) + 4.97) controlPoint1: CGPointMake(CGRectGetMinX(frame) - 0.46, CGRectGetMinY(frame) + 14.41) controlPoint2: CGPointMake(CGRectGetMinX(frame) - 0.99, CGRectGetMinY(frame) + 9.02)];
        [flashOffPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 2.61, CGRectGetMinY(frame) + 3.71) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 1.93, CGRectGetMinY(frame) + 4.54) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 2.25, CGRectGetMinY(frame) + 4.11)];
        [flashOffPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 3.22, CGRectGetMinY(frame) + 3.08) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 2.8, CGRectGetMinY(frame) + 3.49) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 3.01, CGRectGetMinY(frame) + 3.28)];
        [flashOffPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 18.78, CGRectGetMinY(frame) + 3.08) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 7.52, CGRectGetMinY(frame) - 1.03) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 14.48, CGRectGetMinY(frame) - 1.03)];
        [flashOffPath closePath];
        [kIconFill setFill];
        [flashOffPath fill];
        
        
        
    } else if(self.mode == OCCameraFlashIconModeAuto) {
        
        //// flashAuto Drawing
        CGRect frame = CGRectMake(self.bounds.size.width*0.5f - 14.07f*0.5f, self.bounds.size.height*0.5f - 17.f*0.5f, 14.07f, 17.f);
        
        
        //// flashAuto Drawing
        UIBezierPath* flashAutoPath = [UIBezierPath bezierPath];
        [flashAutoPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 2.82, CGRectGetMinY(frame))];
        [flashAutoPath addLineToPoint: CGPointMake(CGRectGetMinX(frame), CGRectGetMinY(frame) + 8.26)];
        [flashAutoPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 4.71, CGRectGetMinY(frame) + 8.26)];
        [flashAutoPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 3.29, CGRectGetMinY(frame) + 12.63)];
        [flashAutoPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.94, CGRectGetMinY(frame) + 12.63)];
        [flashAutoPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 3.76, CGRectGetMinY(frame) + 17)];
        [flashAutoPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 8, CGRectGetMinY(frame) + 12.63)];
        [flashAutoPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 5.65, CGRectGetMinY(frame) + 12.63)];
        [flashAutoPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 8, CGRectGetMinY(frame) + 6.31)];
        [flashAutoPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 3.29, CGRectGetMinY(frame) + 6.31)];
        [flashAutoPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 5.18, CGRectGetMinY(frame))];
        [flashAutoPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 2.82, CGRectGetMinY(frame))];
        [flashAutoPath closePath];
        [flashAutoPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 12.39, CGRectGetMinY(frame) + 4.15)];
        [flashAutoPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 11.52, CGRectGetMinY(frame) + 1.61)];
        [flashAutoPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 10.59, CGRectGetMinY(frame) + 4.15)];
        [flashAutoPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 12.39, CGRectGetMinY(frame) + 4.15)];
        [flashAutoPath closePath];
        [flashAutoPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 11.11, CGRectGetMinY(frame) + 0.76)];
        [flashAutoPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 11.99, CGRectGetMinY(frame) + 0.76)];
        [flashAutoPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 14.07, CGRectGetMinY(frame) + 6.5)];
        [flashAutoPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 13.22, CGRectGetMinY(frame) + 6.5)];
        [flashAutoPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 12.64, CGRectGetMinY(frame) + 4.78)];
        [flashAutoPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 10.37, CGRectGetMinY(frame) + 4.78)];
        [flashAutoPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 9.75, CGRectGetMinY(frame) + 6.5)];
        [flashAutoPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 8.95, CGRectGetMinY(frame) + 6.5)];
        [flashAutoPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 11.11, CGRectGetMinY(frame) + 0.76)];
        [flashAutoPath closePath];
        [kIconFill setFill];
        [flashAutoPath fill];
        
        
            
    }
    
    
}

@end


@class OCCameraFlashButton;

@protocol OCCameraFlashButtonDelegate <NSObject>

- (void)flashButton:(OCCameraFlashButton *)button didChangeMode:(OCCameraFlashIconMode)mode;

@end

//The button that contains the icons for flash
@interface OCCameraFlashButton : UIView {
    OCCameraFlashIcon *flashAutoIcon;
    OCCameraFlashIcon *flashOnIcon;
    OCCameraFlashIcon *flashOffIcon;
    
    OCCameraFlashIconMode mode;
    
    UIView *bgView;
    
    BOOL expanded;
    
    __weak id<OCCameraFlashButtonDelegate> delegate;
}

@property (nonatomic, weak) id<OCCameraFlashButtonDelegate> delegate;

- (void)setMode:(OCCameraFlashIconMode)m;

- (void)collapse;

@end

@implementation OCCameraFlashButton
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if(self) {
        bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        bgView.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.500];
        bgView.layer.cornerRadius = 15.f;
        [self addSubview:bgView];
        
        self.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        tap.cancelsTouchesInView = YES;
        [self addGestureRecognizer:tap];
        
        flashAutoIcon = [[OCCameraFlashIcon alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        flashAutoIcon.mode = OCCameraFlashIconModeAuto;
        [self addSubview:flashAutoIcon];
        
        mode = OCCameraFlashIconModeAuto;
        
        flashOnIcon = [[OCCameraFlashIcon alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        flashOnIcon.mode = OCCameraFlashIconModeOn;
        flashOnIcon.hidden = YES;
        flashOnIcon.alpha = 0.f;
        [self addSubview:flashOnIcon];
        
        flashOffIcon = [[OCCameraFlashIcon alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        flashOffIcon.mode = OCCameraFlashIconModeOff;
        flashOffIcon.hidden = YES;
        flashOffIcon.alpha = 0.f;
        [self addSubview:flashOffIcon];
        
        expanded = NO;
    }
    
    return self;
}

- (void)setMode:(OCCameraFlashIconMode)m {
    if(m != mode) {
        mode = m;
        
        if([delegate respondsToSelector:@selector(flashButton:didChangeMode:)]) {
            [delegate flashButton:self didChangeMode:mode];
        }
    }
}

- (void)collapse {
    if(expanded) {
        expanded = NO;
        if(mode == OCCameraFlashIconModeAuto) {
            [UIView animateWithDuration:0.3f animations:^{
                self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, 30, 30);
                bgView.frame = CGRectMake(0, 0, 30, 30);
                flashAutoIcon.alpha = 1.f;
                flashOnIcon.alpha = 0.f;
                flashOffIcon.alpha = 0.f;
                
                flashAutoIcon.frame = CGRectMake(0, 0, 30, 30);
                flashOnIcon.frame = CGRectMake(0, 0, 30, 30);
                flashOffIcon.frame = CGRectMake(0, 0, 30, 30);
            } completion:^(BOOL finished) {
                flashAutoIcon.hidden = NO;
                flashOnIcon.hidden = YES;
                flashOffIcon.hidden = YES;
            }];
        } else if(mode == OCCameraFlashIconModeOn) {
            [UIView animateWithDuration:0.3f animations:^{
                self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, 30, 30);
                bgView.frame = CGRectMake(0, 0, 30, 30);
                flashAutoIcon.alpha = 0.f;
                flashOnIcon.alpha = 1.f;
                flashOffIcon.alpha = 0.f;
                
                flashAutoIcon.frame = CGRectMake(0, 0, 30, 30);
                flashOnIcon.frame = CGRectMake(0, 0, 30, 30);
                flashOffIcon.frame = CGRectMake(0, 0, 30, 30);
            } completion:^(BOOL finished) {
                flashAutoIcon.hidden = YES;
                flashOnIcon.hidden = NO;
                flashOffIcon.hidden = YES;
            }];
        } else if(mode == OCCameraFlashIconModeOff) {
            [UIView animateWithDuration:0.3f animations:^{
                self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, 30, 30);
                bgView.frame = CGRectMake(0, 0, 30, 30);
                flashAutoIcon.alpha = 0.f;
                flashOnIcon.alpha = 0.f;
                flashOffIcon.alpha = 1.f;
                
                flashAutoIcon.frame = CGRectMake(0, 0, 30, 30);
                flashOnIcon.frame = CGRectMake(0, 0, 30, 30);
                flashOffIcon.frame = CGRectMake(0, 0, 30, 30);
            } completion:^(BOOL finished) {
                flashAutoIcon.hidden = YES;
                flashOnIcon.hidden = YES;
                flashOffIcon.hidden = NO;
            }];
        }
    }
}

- (void)handleTap:(UITapGestureRecognizer *)tap {
    CGPoint point = [tap locationInView:self];
    if(!expanded && CGRectContainsPoint(bgView.frame, point)) {
        expanded = YES;
        
        flashAutoIcon.hidden = NO;
        flashOnIcon.hidden = NO;
        flashOffIcon.hidden = NO;
        
        [UIView animateWithDuration:0.3f animations:^{
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, 110, 30);
            bgView.frame = CGRectMake(0, 0, 110, 30);
            flashAutoIcon.alpha = 1.f;
            flashOnIcon.alpha = 1.f;
            flashOffIcon.alpha = 1.f;
            
            flashAutoIcon.frame = CGRectMake(5, 0, 30, 30);
            flashOnIcon.frame = CGRectMake(40, 0, 30, 30);
            flashOffIcon.frame = CGRectMake(75, 0, 30, 30);
        }];
    } else if(expanded) {
        if(CGRectContainsPoint(flashAutoIcon.frame, point)) {
            [self setMode:OCCameraFlashIconModeAuto];
            [self collapse];
        } else if(CGRectContainsPoint(flashOnIcon.frame, point)) {
            [self setMode:OCCameraFlashIconModeOn];
            [self collapse];
        } else if(CGRectContainsPoint(flashOffIcon.frame, point)) {
            [self setMode:OCCameraFlashIconModeOff];
            [self collapse];
        }
    }
}

@end

//Resolution independent vector focus view
@interface OCCameraFocusView : UIView

@end

@implementation OCCameraFocusView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if(self) {
        self.backgroundColor = [UIColor clearColor];
        self.layer.shouldRasterize = YES;
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect {
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* focusHighlightColor = [UIColor colorWithRed: 0.619f green: 0.789f blue: 0.951f alpha: 1.f];
    
    //// Shadow Declarations
    UIColor* lightShadow = [UIColor whiteColor];
    CGSize lightShadowOffset = CGSizeMake(0.f, 0.f);
    CGFloat lightShadowBlurRadius = 2.5f;
    
    //// Frames
    //    CGRect frame = CGRectMake(0.f, 0.f, 100, 100);
    const CGFloat frameInset = 5.f;
    CGRect frame = CGRectInset(self.bounds, frameInset, frameInset);
    
    const CGFloat circleRadius = floorf(frame.size.width*0.5f*0.9f);
    
    
    //// Oval Drawing
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMidX(frame) - circleRadius, CGRectGetMidY(frame) - circleRadius, 2.f*circleRadius, 2.f*circleRadius)];
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, lightShadowOffset, lightShadowBlurRadius, lightShadow.CGColor);
    [[UIColor whiteColor] setStroke];
    ovalPath.lineWidth = 1.f;
    [ovalPath stroke];
    CGContextRestoreGState(context);
    
    
    const CGFloat centerSquareSize = roundf(frame.size.width*0.1f);
    
    //// centerSquare Drawing
    UIBezierPath* centerSquarePath = [UIBezierPath bezierPathWithRect: CGRectMake(floorf(CGRectGetMidX(frame) - centerSquareSize*0.5f), floorf(CGRectGetMidY(frame) - centerSquareSize*0.5f), centerSquareSize, centerSquareSize)];
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, lightShadowOffset, lightShadowBlurRadius, lightShadow.CGColor);
    [focusHighlightColor setStroke];
    centerSquarePath.lineWidth = 1.f;
    [centerSquarePath stroke];
    CGContextRestoreGState(context);
    
    
    
    
    
    //// centerMarkers Drawing
    
    const CGFloat circleMarkerLength = circleRadius*0.2f;
    
    CGFloat radialOffset = sinf(M_PI_4)*circleRadius;
    CGFloat radialInset = sinf(M_PI_4)*circleMarkerLength;
    
    {
        //compute starting point of upper left line
        CGPoint startPoint = CGPointMake(CGRectGetMidX(frame) - radialOffset, CGRectGetMidY(frame) - radialOffset);
        CGPoint endPoint = CGPointMake(startPoint.x + radialInset, startPoint.y + radialInset);
        
        //Draw Upper Left line
        UIBezierPath* bezierPath = [UIBezierPath bezierPath];
        [bezierPath moveToPoint: startPoint];
        [bezierPath addLineToPoint: endPoint];
        CGContextSaveGState(context);
        CGContextSetShadowWithColor(context, lightShadowOffset, lightShadowBlurRadius, lightShadow.CGColor);
        [[UIColor whiteColor] setStroke];
        bezierPath.lineWidth = 1;
        [bezierPath stroke];
        CGContextRestoreGState(context);
    }
    
    {
        //compute starting point of lower left line
        CGPoint startPoint = CGPointMake(CGRectGetMidX(frame) - radialOffset, CGRectGetMidY(frame) + radialOffset);
        CGPoint endPoint = CGPointMake(startPoint.x + radialInset, startPoint.y - radialInset);
        
        //Draw Upper Left line
        UIBezierPath* bezierPath = [UIBezierPath bezierPath];
        [bezierPath moveToPoint: startPoint];
        [bezierPath addLineToPoint: endPoint];
        CGContextSaveGState(context);
        CGContextSetShadowWithColor(context, lightShadowOffset, lightShadowBlurRadius, lightShadow.CGColor);
        [[UIColor whiteColor] setStroke];
        bezierPath.lineWidth = 1;
        [bezierPath stroke];
        CGContextRestoreGState(context);
    }
    
    {
        //compute starting point of upper right line
        CGPoint startPoint = CGPointMake(CGRectGetMidX(frame) + radialOffset, CGRectGetMidY(frame) - radialOffset);
        CGPoint endPoint = CGPointMake(startPoint.x - radialInset, startPoint.y + radialInset);
        
        //Draw Upper Left line
        UIBezierPath* bezierPath = [UIBezierPath bezierPath];
        [bezierPath moveToPoint: startPoint];
        [bezierPath addLineToPoint: endPoint];
        CGContextSaveGState(context);
        CGContextSetShadowWithColor(context, lightShadowOffset, lightShadowBlurRadius, lightShadow.CGColor);
        [[UIColor whiteColor] setStroke];
        bezierPath.lineWidth = 1;
        [bezierPath stroke];
        CGContextRestoreGState(context);
    }
    
    {
        //compute starting point of lower right line
        CGPoint startPoint = CGPointMake(CGRectGetMidX(frame) + radialOffset, CGRectGetMidY(frame) + radialOffset);
        CGPoint endPoint = CGPointMake(startPoint.x - radialInset, startPoint.y - radialInset);
        
        //Draw Upper Left line
        UIBezierPath* bezierPath = [UIBezierPath bezierPath];
        [bezierPath moveToPoint: startPoint];
        [bezierPath addLineToPoint: endPoint];
        CGContextSaveGState(context);
        CGContextSetShadowWithColor(context, lightShadowOffset, lightShadowBlurRadius, lightShadow.CGColor);
        [[UIColor whiteColor] setStroke];
        bezierPath.lineWidth = 1;
        [bezierPath stroke];
        CGContextRestoreGState(context);
    }
    
    
    const CGFloat frameMarkerLength = roundf(frame.size.width*0.1f);
    
    //// frameUpperLeftTop Drawing
    UIBezierPath* frameUpperLeftTopPath = [UIBezierPath bezierPathWithRect: CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame), frameMarkerLength, 1)];
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, lightShadowOffset, lightShadowBlurRadius, lightShadow.CGColor);
    [focusHighlightColor setFill];
    [frameUpperLeftTopPath fill];
    CGContextRestoreGState(context);
    
    
    
    //// frameUpperLeftBottom Drawing
    UIBezierPath* frameUpperLeftBottomPath = [UIBezierPath bezierPathWithRect: CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame), 1, frameMarkerLength)];
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, lightShadowOffset, lightShadowBlurRadius, lightShadow.CGColor);
    [focusHighlightColor setFill];
    [frameUpperLeftBottomPath fill];
    CGContextRestoreGState(context);
    
    
    
    //// frameLowerLeftBottom Drawing
    UIBezierPath* frameLowerLeftBottomPath = [UIBezierPath bezierPathWithRect: CGRectMake(CGRectGetMinX(frame), CGRectGetMaxY(frame) - 1, frameMarkerLength, 1)];
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, lightShadowOffset, lightShadowBlurRadius, lightShadow.CGColor);
    [focusHighlightColor setFill];
    [frameLowerLeftBottomPath fill];
    CGContextRestoreGState(context);
    
    
    
    //// frameLowerLeftTop Drawing
    UIBezierPath* frameLowerLeftTopPath = [UIBezierPath bezierPathWithRect: CGRectMake(CGRectGetMinX(frame), CGRectGetMaxY(frame) - frameMarkerLength, 1, frameMarkerLength)];
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, lightShadowOffset, lightShadowBlurRadius, lightShadow.CGColor);
    [focusHighlightColor setFill];
    [frameLowerLeftTopPath fill];
    CGContextRestoreGState(context);
    
    
    
    //// frameLowerRightBottom Drawing
    UIBezierPath* frameLowerRightBottomPath = [UIBezierPath bezierPathWithRect: CGRectMake(CGRectGetMaxX(frame) - frameMarkerLength, CGRectGetMaxY(frame) - 1, frameMarkerLength, 1)];
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, lightShadowOffset, lightShadowBlurRadius, lightShadow.CGColor);
    [focusHighlightColor setFill];
    [frameLowerRightBottomPath fill];
    CGContextRestoreGState(context);
    
    
    
    //// frameLowerRightTop Drawing
    UIBezierPath* frameLowerRightTopPath = [UIBezierPath bezierPathWithRect: CGRectMake(CGRectGetMaxX(frame) - 1, CGRectGetMaxY(frame) - frameMarkerLength, 1, frameMarkerLength)];
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, lightShadowOffset, lightShadowBlurRadius, lightShadow.CGColor);
    [focusHighlightColor setFill];
    [frameLowerRightTopPath fill];
    CGContextRestoreGState(context);
    
    
    
    //// frameUpperRightTop Drawing
    UIBezierPath* frameUpperRightTopPath = [UIBezierPath bezierPathWithRect: CGRectMake(CGRectGetMaxX(frame) - frameMarkerLength, CGRectGetMinY(frame), frameMarkerLength, 1)];
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, lightShadowOffset, lightShadowBlurRadius, lightShadow.CGColor);
    [focusHighlightColor setFill];
    [frameUpperRightTopPath fill];
    CGContextRestoreGState(context);
    
    
    
    //// frameUpperRightBottom Drawing
    UIBezierPath* frameUpperRightBottomPath = [UIBezierPath bezierPathWithRect: CGRectMake(CGRectGetMaxX(frame) - 1, CGRectGetMinY(frame), 1, frameMarkerLength)];
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, lightShadowOffset, lightShadowBlurRadius, lightShadow.CGColor);
    [focusHighlightColor setFill];
    [frameUpperRightBottomPath fill];
    CGContextRestoreGState(context);
}

@end



#pragma mark - Camera view controller

#define kBottomBarHeight 60

@interface OCCameraViewController () <UIGestureRecognizerDelegate, OCCameraSwitchDelegate, OCCameraFlashButtonDelegate> {
    NSArray *dividerLayers;
    
    OCCameraFocusView *focusView;
    
    UIView *bottomBarView;
    
    UIView *flashView;
    
    OCCameraFlashButton *flashButton;
    
    OCCameraButton *cameraButton;
    
    OCCameraSwitch *cameraSwitch;
    
    BOOL currentlyTakingPhoto;
    
    BOOL currentlyRecordingVideo;
}

@end

@implementation OCCameraViewController
@synthesize mode;
@synthesize delegate;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self initializeCamView];
    
    [self initializeFlashIcon];
    
    [self initializeDividers];
    
    [self initializeFocusView];
    
    [self initializeBottomBar];
    
    [self fadeInDividers];
    
    currentlyTakingPhoto = NO;
    currentlyRecordingVideo = NO;
}

#pragma mark - View Initialization

- (void)initializeCamView {
    UIView *camContainerView = [[UIView alloc] initWithFrame:self.view.bounds];
    
    self.cam = [[DIYCam alloc] initWithFrame:self.view.bounds];
    self.cam.layer.anchorPoint = CGPointMake(0.f, 0.f);
    self.cam.frame = self.view.bounds;
    self.cam.delegate       = self;
    [self.cam setupWithOptions:nil];
    [self.cam setCamMode:DIYAVModePhoto];
    
    [camContainerView addSubview:self.cam];
    [self.view addSubview:camContainerView];
    
    flashView = [[UIView alloc] initWithFrame:self.cam.frame];
    flashView.backgroundColor = [UIColor whiteColor];
    flashView.hidden = YES;
    [self.view addSubview:flashView];
}

- (void)initializeFlashIcon {
    flashButton = [[OCCameraFlashButton alloc] initWithFrame:CGRectMake(10, 10, 30, 30)];
    flashButton.layer.zPosition = 5;
    flashButton.delegate = self;
    [self.view addSubview:flashButton];
}

- (void)initializeBottomBar {
    bottomBarView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - kBottomBarHeight, self.view.bounds.size.width, kBottomBarHeight)];
    bottomBarView.backgroundColor = kBottomBarFill;
    bottomBarView.layer.zPosition = 3;
    [self.view addSubview:bottomBarView];
    
    cameraButton = [[OCCameraButton alloc] initWithFrame:CGRectMake(floorf(bottomBarView.bounds.size.width*0.5f - 60.f*0.5f), self.view.bounds.size.height - 67.f - 10.f, 60.f, 67.f)];
    cameraButton.layer.zPosition = 4;
    [cameraButton addTarget:self action:@selector(capture:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cameraButton];
    
    CGFloat switchInset = floorf((kBottomBarHeight - 28.f)*0.5f);
    
    cameraSwitch = [[OCCameraSwitch alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 80.f - switchInset, switchInset, 80, 28)];
    cameraSwitch.delegate = self;
    [bottomBarView addSubview:cameraSwitch];
}

- (void)initializeFocusView {
    focusView = [[OCCameraFocusView alloc] initWithFrame:CGRectMake(0.f, 0.f, 76.f, 76.f)];
    focusView.alpha = 0.f;
    focusView.hidden = YES;
    [self.view addSubview:focusView];
}

- (void)initializeDividers {
    //Add grid lines
    int divisions = 3;
    
    NSMutableArray *tempDividerLines = [[NSMutableArray alloc] initWithCapacity:divisions*4];
    
    //vertical and horizontal
    for(int i = 0; i < divisions-1; i++) {
        CGFloat yOrigin = floorf((self.view.bounds.size.height/divisions)*(i+1));
        CALayer *horizontalLayerWhite = [CALayer layer];
        horizontalLayerWhite.frame = CGRectMake(0.f, yOrigin - 0.5f, self.view.bounds.size.width, 1.f);
        horizontalLayerWhite.backgroundColor = [UIColor colorWithWhite:1.f alpha:0.2f].CGColor;
        horizontalLayerWhite.opacity = 0.f;
        horizontalLayerWhite.zPosition = 2;
        [self.view.layer addSublayer:horizontalLayerWhite];
        [tempDividerLines addObject:horizontalLayerWhite];
        
        CALayer *horizontalLayerBlack = [CALayer layer];
        horizontalLayerBlack.frame = CGRectMake(0.f, yOrigin+0.5f, self.view.bounds.size.width, 0.5f);
        horizontalLayerBlack.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.2f].CGColor;
        horizontalLayerBlack.opacity = 0.f;
        horizontalLayerBlack.zPosition = 2;
        [self.view.layer addSublayer:horizontalLayerBlack];
        [tempDividerLines addObject:horizontalLayerBlack];
        
        CGFloat xOrigin = floorf((self.view.bounds.size.width/divisions)*(i+1));
        CALayer *verticalLayerWhite = [CALayer layer];
        verticalLayerWhite.frame = CGRectMake(xOrigin - 0.5f, 0.f, 1.f, self.view.bounds.size.height);
        verticalLayerWhite.backgroundColor = [UIColor colorWithWhite:1.f alpha:0.2f].CGColor;
        verticalLayerWhite.opacity = 0.f;
        verticalLayerWhite.zPosition = 2;
        [self.view.layer addSublayer:verticalLayerWhite];
        [tempDividerLines addObject:verticalLayerWhite];
        
        CALayer *verticalLayerBlack = [CALayer layer];
        verticalLayerBlack.frame = CGRectMake(xOrigin+0.5f, 0.f, 0.5f, self.view.bounds.size.height);
        verticalLayerBlack.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.2f].CGColor;
        verticalLayerBlack.opacity = 0.f;
        verticalLayerBlack.zPosition = 2;
        [self.view.layer addSublayer:verticalLayerBlack];
        [tempDividerLines addObject:verticalLayerBlack];
    }
    
    dividerLayers = [NSArray arrayWithArray:tempDividerLines];
}

#pragma mark - Animations

- (void)fadeInDividers {
    [dividerLayers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self fadeInLayer:obj];
    }];
}

- (void)fadeOutDividersRemoveOnCompletion:(BOOL)remove {
    [dividerLayers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self fadeOutLayer:obj];
    }];
    
    if(remove) {
        [dividerLayers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.25f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [(CALayer *)obj removeFromSuperlayer];
            });
        }];
    }
}

- (void)fadeInLayer:(CALayer *)layer {
    //FADE IN
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.duration = 0.25f;
    animation.fromValue = [NSNumber numberWithFloat:0.0f];
    animation.toValue = [NSNumber numberWithFloat:1.0f];
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeBoth;
    animation.additive = NO;
    [layer addAnimation:animation forKey:@"opacityIN"];
}

- (void)fadeOutLayer:(CALayer *)layer {
    //FADE OUT
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.duration = 0.25f;
    animation.fromValue = [NSNumber numberWithFloat:1.0f];
    animation.toValue = [NSNumber numberWithFloat:0.0f];
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeBoth;
    animation.additive = NO;
    [layer addAnimation:animation forKey:@"opacityOUT"];
}

#pragma mark - Rotations

- (BOOL)shouldAutorotate {
    return NO;
}

- (void)didRotate:(NSNotification *)notification {
    
    [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
        if (orientation == UIDeviceOrientationPortrait) {
            CGAffineTransform rotate = CGAffineTransformMakeRotation (0.0);
            cameraButton.transform = rotate;
        } else if (orientation == UIDeviceOrientationPortraitUpsideDown) {
            CGAffineTransform rotate = CGAffineTransformMakeRotation (M_PI * 180 / 180.0f);
            cameraButton.transform = rotate;
        } else if (orientation == UIDeviceOrientationLandscapeLeft) {
            CGAffineTransform rotate = CGAffineTransformMakeRotation (M_PI * 90 / 180.0f);
            cameraButton.transform = rotate;
        } else if (orientation == UIDeviceOrientationLandscapeRight) {
            CGAffineTransform rotate = CGAffineTransformMakeRotation (M_PI * 270 / 180.0f);
            cameraButton.transform = rotate;
        }
    } completion:nil];

}

#pragma mark - Flash delegate

- (void)flashButton:(OCCameraFlashButton *)button didChangeMode:(OCCameraFlashIconMode)m {
    if(m == OCCameraFlashIconModeAuto) {
        [self.cam.diyAV setFlashMode:DIYAVFlashModeAuto];
    } else if(m == OCCameraFlashIconModeOn) {
        [self.cam.diyAV setFlashMode:DIYAVFlashModeOn];
    } else if(m == OCCameraFlashIconModeOff) {
        [self.cam.diyAV setFlashMode:DIYAVFlashModeOff];
    }
}

#pragma mark - Switch Delegate

- (void)cameraSwitchChangedModes:(OCCameraSwitchMode)m {
    if(m == OCCameraSwitchModePicture) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.cam setCamMode:DIYAVModePhoto];
        });
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.cam setCamMode:DIYAVModeVideo];
        });
    }
}

#pragma mark - Actions

- (void)capture:(id)sender
{
    if ([self.cam getCamMode] == DIYAVModePhoto) {
        if([self.cam.diyAV ready]) {
            currentlyTakingPhoto = NO;
            [self.cam capturePhoto];
            
            flashView.alpha = 0.6f;
            flashView.hidden = NO;
            
            [UIView animateWithDuration:0.3f animations:^{
                flashView.alpha = 0.f;
            } completion:^(BOOL finished) {
                flashView.hidden = YES;
            }];
        } else {
            [self performSelector:@selector(capture:) withObject:nil afterDelay:0.2f];
        }
    } else if([self.cam getCamMode] == DIYAVModeVideo) {
        if ([self.cam getRecordingStatus]) {
            [cameraButton setRecording:NO];
            [self.cam captureVideoStop];
        }
        else {
            [cameraButton setRecording:YES];
            [self.cam captureVideoStart];
        }
    }
}

#pragma mark - DIYCamDelegate

- (void)camReady:(DIYCam *)cam
{
    //NSLog(@"Ready");
}

- (void)camDidFail:(DIYCam *)cam withError:(NSError *)error
{
    //NSLog(@"Fail");
}

- (void)camModeWillChange:(DIYCam *)cam mode:(DIYAVMode)mode
{
    //NSLog(@"Mode will change");
}

- (void)camModeDidChange:(DIYCam *)cam mode:(DIYAVMode)mode
{
    //NSLog(@"Mode did change");
}

- (void)camCaptureStarted:(DIYCam *)cam
{
    //NSLog(@"Capture started");
}

- (void)camCaptureStopped:(DIYCam *)cam
{
    //NSLog(@"Capture stopped");
}

- (void)camCaptureProcessing:(DIYCam *)cam
{
    //NSLog(@"Capture processing");
}

- (void)camCaptureComplete:(DIYCam *)cam withAsset:(NSDictionary *)asset
{
    if([asset[@"type"] isEqualToString:@"video"]) {
        if([delegate respondsToSelector:@selector(camera:didTakeVideo:)]) {
            [delegate camera:self didTakeVideo:asset[@"path"]];
        }
    } else if([asset[@"type"] isEqualToString:@"image"]) {
        if([delegate respondsToSelector:@selector(camera:didTakePhoto:)]) {
            [delegate camera:self didTakePhoto:asset[@"path"]];
        }
    }
}

#pragma mark - Touch handlers

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if(event.allTouches.count == 1) {
        UITouch *touch = event.allTouches.anyObject;
        CGPoint point = [touch locationInView:self.cam];
        if(point.y < self.view.bounds.size.height - kBottomBarHeight) {
            focusView.center = point;
            [self animateFocusImage];
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if(event.allTouches.count == 1) {
        UITouch *touch = event.allTouches.anyObject;
        CGPoint point = [touch locationInView:self.cam];
        if(point.y < self.view.bounds.size.height - kBottomBarHeight) {
            focusView.center = point;
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if(event.allTouches.count == 1) {
        UITouch *touch = event.allTouches.anyObject;
        CGPoint point = [touch locationInView:self.cam];
        if(point.y < self.view.bounds.size.height - kBottomBarHeight) {
        focusView.center = point;
            [self.cam.diyAV focusAtPoint:point inFrame:self.cam.frame];
            [self.cam.diyAV exposeAtPoint:point inFrame:self.cam.bounds];
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [UIView animateWithDuration:0.25f animations:^{
        focusView.alpha = 0.f;
    } completion:^(BOOL finished) {
        focusView.hidden = YES;
    }];
}

#pragma mark - Focus reticle

- (void)animateFocusImage
{
    focusView.alpha = 0.f;
    focusView.hidden = NO;
    
    [UIView animateWithDuration:0.1f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        focusView.alpha = 1.f;
        focusView.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            focusView.transform = CGAffineTransformIdentity;
        } completion:nil];
    }];
    
}

#pragma mark - UIGestureRecognizer Delegate

// We're running two UIGestureRecognizers attached to cam at once. One has this
// ViewController as its target to handle the UI display side. The other is internal
// to cam and actually adjusts the focus. Implementing this delegate method allows
// both gesture regonizers to fire with the same tap.
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return true;
}

@end
