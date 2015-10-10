# ICGVideoTrimmer
A library for quick video trimming based on `SAVideoRangeSlider`, mimicking the behavior of Instagram's.

![Screenshot](https://raw.githubusercontent.com/itsmeichigo/ICGVideoTrimmer/master/trimmer.gif)

## Note
I've made this very quickly so here's a list of things to do for improvements (pull requests are very much appreciated!):
- ~~Make panning thumb views smoother~~
- ~~Make ruller view more customizable~~
- ~~Added video tracker, mimicking the behaviour of Instagram's~~ - [@FabKremer](https://github.com/FabKremer)
- Bug fixes if any
- More and more, can't remember right now hahha.

## Getting started

#### Using CocoaPods:
  Just add the following line in to your pod file:
  
	pod 'ICGVideoTrimmer'

#### Manually add ICGVideoTrimmer as a library:
  Drag and drop the subfolder named `Source` in your project and you are done.

### Usage
Create an instance of `ICGVideoTrimmer` using interface builder or programmatically. Give it an asset and set the delegate. You can select theme color for the trimmer view and decide whether to show the ruler view by setting the properties. Finally, don't forget to call `resetSubviews`!
 ```objective-C
  [self.trimmerView setThemeColor:[UIColor lightGrayColor]];
  [self.trimmerView setAsset:self.asset];
  [self.trimmerView setShowsRulerView:YES];
  [self.trimmerView setTrackerColor:[UIColor cyanColor]];
  [self.trimmerView setShowsTracker:YES];
  [self.trimmerView setDelegate:self];
  [self.trimmerView resetSubviews];
 ```
If necessary, you can also set your desired minimum and maximum length for your trimmed video by setting the properties `minLength` and `maxLength` for the trimmer view. By default, these properties are 3 and 15 (seconds) respectively.

You can also customize your thumb views by setting images for the left and right thumbs:
```objective-C
  [self.trimmerView setLeftThumbImage:[UIImage imageNamed:@"left-thumb"]];
  [self.trimmerView setRightThumbImage:[UIImage imageNamed:@"right-thumb"]];
```
See the project example to see how to manage the tracker on a video. 

## Requirements

ICGVideoTrimmer requires iOS 7 and `MobileCoreServices` and `AVFoundation` frameworks. Honestly I haven't tested it with iOS 6 and below so I can't be too sure if it's compatible.

### ARC

ICGVideoTrimmer uses ARC. If you are using ICGVideoTrimmer in a non-arc project, you
will need to set a `-fobjc-arc` compiler flag on every ICGVideoTrimmer source files. To set a
compiler flag in Xcode, go to your active target and select the "Build Phases" tab. Then select
ICGVideoTrimmer source files, press Enter, insert -fobjc-arc and then "Done" to enable ARC
for ICGVideoTrimmer.

## Contributing

Contributions for bug fixing or improvements are welcome. Feel free to submit a pull request.

## Licence

ICGVideoTrimmer is available under the MIT license. See the LICENSE file for more info.
