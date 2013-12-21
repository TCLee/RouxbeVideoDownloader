#RouxbeVideoDownloader

This Mac OS X app downloads videos from rouxbe.com

#### How to Use the App
1. Copy and paste a URL from rouxbe.com. Example: http://rouxbe.com/cooking-school/lessons/240-eggs-frying-basting-poaching
2. Press Return/Enter to begin downloads.

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
- AFNetworking
- OCMock
- Expecta
- OHHTTPStubs

##License
This project's source code is provided for educational purposes only. Street View logo is the copyright of Google. See the LICENSE file for more info.
