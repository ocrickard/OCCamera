#OCCamera#

This demo is a quick camera implementation I've thrown together over a weekend.  It is very beta, but has many of the features that you would expect from a camera on iOS.  It is fully native, and uses NO external assets.  All icons/buttons are drawn using CoreGraphics or QuartzCore.  The demo app is built on the very excellent DIYAV and DIYCam projects, which have been modified slightly, and I need to separate them into separate forks from the root repos.

![Screenshot](https://raw.github.com/ocrickard/OCCamera/master/screenshot.png)

##Structure##

I've put a number of classes in the OCCameraViewController.h and .m files.  The idea was to keep it encapsulated, though the dependencies on the DIYAV and DIYCam libraries keep it from being a true 2-file camera component.

##Installation##

1.  Drag in the DIYAV and DIYCam directories into your project.

2.  Drag in the OCCameraViewController.h and OCCameraViewController.m files into your project.

3.  Make sure you have all of the following frameworks:  MobileCoreServices.framework, AssetsLibrary.framework, CoreMedia.framework, QuartzCore.framework, AVFoundation.framework, UIKit.framework, Foundation.framework, CoreGraphics.framework.

4.  Allocate/init the view controller where you need a controller, and present the controller to the user:

```
camController = [[OCCameraViewController alloc] init];
camController.delegate = self;
[myViewController presentViewController:camController animated:YES completion:nil];
```

5.  Implement the two delegate methods:

```
#pragma mark - OCCameraViewControllerDelegate 

- (void)camera:(OCCameraViewController *)cameraViewController didTakePhoto:(NSString *)pathToPhoto {
    NSLog(@"took photo:%@", pathToPhoto);
}

- (void)camera:(OCCameraViewController *)cameraViewController didTakeVideo:(NSString *)pathToVideo {
    NSLog(@"took video:%@", pathToVideo);
}
```

6.  Tweak and enjoy!

##TODO##

1.  Finish up the flash button.  It still has some problems, and I need to test the flash modes more.

2.  Test implementation on more devices (I've only tested on my iPhone 5).

3. Generalize all components.  At the moment, I've written somewhat static components that should be generalized.

#License#

OCCamera is released under the *MIT License*.

Copyright (c) 2013 Oliver C. Rickard

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
