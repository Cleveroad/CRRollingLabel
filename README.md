## CRRollingLabel [![Awesome](https://cdn.rawgit.com/sindresorhus/awesome/d7305f38d29fed78fa85652e3a63e154dd8e8829/media/badge.svg)](https://github.com/sindresorhus/awesome) <img src="https://www.cleveroad.com/public/comercial/label-ios.svg" height="20"> <a href="https://www.cleveroad.com/?utm_source=github&utm_medium=label&utm_campaign=contacts"><img src="https://www.cleveroad.com/public/comercial/label-cleveroad.svg" height="20"></a>

CRRollingLabel provides an animated text change, as a scrolling column. CRRollingLabel is subclass of UILabel, so it supports all functions of UILabel without any additional configuration, but limited to display only numeric values. 

<img src="http://i1155.photobucket.com/albums/p541/Nick_Pro/ezgif.com-video-to-gif%201_zps15qjf4hr.gif">

##Installation
####CocoaPods
CRRollingLabel is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:
Add `pod 'CRRollingLabel'` to your Podfile and run `pod install` in terminal.

####Manually
Add the `CRRollingLabel` folder to your project.  CRRollingLabel uses ARC. If you have a project that doesn't use ARC, just add the `-fobjc-arc` compiler flag to the CRRollingLabel files.

## Usage

The `CRRollingLabel` is extremely easy to use.  CRRollingLabel is subclass of UILabel, so you do not need any additional configuration.

```objective-c
#import <CRRollingLabel/CRRollingLabel.h>
```

```objective-c
CRRollingLabel *rollingLabel = [[CRRollingLabel alloc] initWithFrame:CGRectMake(0.f, 0.f, 100.f, 100.f)];
[self.view addSubview:rollingLabel];
rollingLabel.text = @"43";
```

Changing label value is animated by default, but it is possible to set values without animation. See `CRRollingLabel.h` file for details.

##Limitations

The `CRRollingLabel` is currently support only one line of text.
The `CRRollingLabel` is currently limited to work only with numerical values. Non-numeric values are ignored.
The `CRRollingLabel` currently not working properly with attributedText with different fonts,  placed in one `NSAttributedString`.
The `NSLineBreakMode` is currently not working properly. Please, use autoshrink instead to achieve the result.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Support
If you have any questions, please contact us for support at info@cleveroad.com (email subject: «CRRollingLabel support.»)
<br>or
<br>Use our contacts:
<br><a href="https://www.cleveroad.com/?utm_source=github&utm_medium=link&utm_campaign=contacts">Cleveroad.com</a>
<br><a href="https://www.facebook.com/cleveroadinc">Facebook account</a>
<br><a href="https://twitter.com/CleveroadInc">Twitter account</a>
<br><a href="https://www.youtube.com/c/Cleveroadinc">Youtube account</a>
<br><a href="https://plus.google.com/+CleveroadInc/">Google+ account</a>
<br><a href="https://www.linkedin.com/company/cleveroad-inc-">LinkedIn account</a>
<br><a href="https://dribbble.com/cleveroad">Dribbble account</a>

## License

CRRollingLabel is available under the MIT license. See the LICENSE file for more info.
