#RouxbeVideoDownloader

An easy to use app to save videos from [rouxbe.com](http://rouxbe.com) for offline viewing.

By default, rouxbe.com only provides a way for you to stream their videos. However, it is much more convenient to be able to download the videos to your device and view them anytime without an Internet connection.

![Screenshot of Rouxbe Video Downloader App](http://tclee.github.io/RouxbeVideoDownloader/images/Screenshot.png "Screenshot")

#### How to use the app?
1. Copy and paste a URL from rouxbe.com. Example: http://rouxbe.com/cooking-school/lessons/240-eggs-frying-basting-poaching
2. Press `Return/Enter` to add downloads to the queue.

####Features
* Very easy to get started. Just copy and paste a URL to add downloads to the download queue.
* Downloaded Lesson and Recipe videos are automatically organized into folders. Videos are also renamed to match the correct order of the Lesson's or Recipe's steps.
* Videos are saved in MP4 format, so you can view them on your iOS devices.
* Downloads are resumable even after you quit the app.
* You can limit the number of video downloads that can run concurrently to manage your bandwidth.

##How to Build and Run

<dl>
  <dt>Build Requirements</dt>
  <dd>Xcode 5, Mac OS X 10.9 SDK, CocoaPods</dd>
  <dt>Runtime Requirements</dt>
  <dd>Mac OS X 10.9 or later</dd>
</dl>

####Step 1: Download and Install CocoaPods
If you've already installed CocoaPods, you can skip to **Step 2**.  
Otherwise, install CocoaPods by following the quick installation guide at <http://cocoapods.org/>.

####Step 2: Install Library Dependencies
This sample app needs to download and install the required libraries before it can be build. We'll let CocoaPods do all the hard work for us.

Run the following commands in `Terminal.app`: 
```
$ cd RouxbeVideoDownloader
$ pod install  
$ open RouxbeVideoDownloader.xcworkspace
```

###Unit Tests
RouxbeVideoDownloader includes a suite of unit tests in the `RouxbeVideoDownloaderTests` directory. The unit test framework used is **XCTest**, so you can run the unit tests easily from XCode using the shortcut &#8984;U.

##Open Source Libraries Used
* [AFNetworking](https://github.com/AFNetworking/AFNetworking) - A delightful Objective-C networking library.
* [RaptureXML](https://github.com/ZaBlanc/RaptureXML) - Simple block-based XML library.
* [OCMock](https://github.com/erikdoe/ocmock) - Objective-C implementation of mock objects.
* [Expecta](https://github.com/specta/expecta) - A matcher framework for Objective-C.
* [OHHTTPStubs](https://github.com/AliSoftware/OHHTTPStubs) - Stub network requests easily for testing.

##License
This project's source code is provided for educational purposes only. Please see Rouxbe's Terms and Conditions before downloading any video. See the LICENSE file for more info.
