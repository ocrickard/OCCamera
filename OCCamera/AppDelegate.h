//
//  AppDelegate.h
//  OCCamera
//
//  Created by Oliver Rickard on 02/02/2013.
//  Copyright (c) 2013 Oliver Rickard. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OCCameraViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, OCCameraViewControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) OCCameraViewController *viewController;

@end
