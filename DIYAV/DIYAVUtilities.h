//
//  DIYAVUtilities.h
//  DIYAV
//
//  Created by Jonathan Beilin on 1/22/13.
//  Copyright (c) 2013 DIY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class DIYAVPreview;

typedef enum {
    DIYAVFlashModeOn,
    DIYAVFlashModeOff,
    DIYAVFlashModeAuto
} DIYAVFlashMode;

@interface DIYAVUtilities : NSObject

+ (AVCaptureDevice *)cameraInPosition:(AVCaptureDevicePosition)position;
+ (BOOL)isPhotoCameraAvailable;
+ (BOOL)isVideoCameraAvailable;
+ (AVCaptureConnection *)connectionWithMediaType:(NSString *)mediaType fromConnections:(NSArray *)connections;

+ (void)setFlash:(BOOL)flash forCameraInPosition:(AVCaptureDevicePosition)position;
+ (void)setFlashMode:(DIYAVFlashMode)flashMode forCameraInPosition:(AVCaptureDevicePosition)position;
+ (void)setHighISO:(BOOL)highISO forCameraInPosition:(AVCaptureDevicePosition)position;

+ (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates withFrame:(CGRect)frame withPreview:(DIYAVPreview *)preview withPorts:(NSArray *)ports;

+ (AVCaptureVideoOrientation)getAVVideoCaptureOrientationFromDeviceOrientation;
+ (AVCaptureVideoOrientation)getAVPictureCaptureOrientationFromDeviceOrientation;

+ (NSString *)createAssetFilePath:(NSString *)extension;

@end
