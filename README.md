## Getting Started

You'll need cocoapods installed. Once installed run `pod install` and open `Reddit.xcworkspace` you should then be able to build for the simulator.

## Differences from App Store Version

You'll notice a few differences from the version found in the app store.

* Signing entitlements are removed, if you want to build the app you'll need to add your own.
* iCloud sync has been removed. This was due to how it was set up and tied to my account.
* Pro features are not behind any paywall and IAP service has been removed from the app.

## Code Structure

This project has gone through many different rewrites as I've wanted to explore different archetectures and try new things. Given, such a large project like this is not a great way to do that, but some code has been left over. You'll notice there's a `cleaned` and `old` directory. I started reworking a lot of the code to clean things up a while back, but never made it all the way through. Thus, the two directories.
