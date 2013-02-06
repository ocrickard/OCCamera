//
//  OCCameraViewController.h
//  OCCamera
//
//  Created by Oliver Rickard on 02/02/2013.
//  Copyright (c) 2013 Oliver Rickard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DIYCam.h"

typedef enum {
    OCCameraModePicture,
    OCCameraModeVideo
} OCCameraMode;

@class OCCameraViewController;

@protocol OCCameraViewControllerDelegate <NSObject>

- (void)camera:(OCCameraViewController *)cameraViewController didTakePhoto:(NSString *)pathToPhoto;
- (void)camera:(OCCameraViewController *)cameraViewController didTakeVideo:(NSString *)pathToVideo;

@end

@interface OCCameraViewController : UIViewController <DIYCamDelegate> {
    __weak id<OCCameraViewControllerDelegate> delegate;
}

@property (nonatomic, strong) DIYCam *cam;
@property (nonatomic, assign) OCCameraMode mode;
@property (nonatomic, weak) id<OCCameraViewControllerDelegate> delegate;

@end
