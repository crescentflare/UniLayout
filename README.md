# UniLayout

[![CI Status](http://img.shields.io/travis/crescentflare/UniLayout.svg?style=flat)](https://travis-ci.org/crescentflare/UniLayout)
[![License](https://img.shields.io/cocoapods/l/UniLayout.svg?style=flat)](http://cocoapods.org/pods/UniLayout)
[![Version](https://img.shields.io/cocoapods/v/UniLayout.svg?style=flat)](http://cocoapods.org/pods/UniLayout)
[![Version](https://img.shields.io/bintray/v/crescentflare/maven/UniLayoutLib.svg?style=flat)](https://bintray.com/crescentflare/maven/UniLayoutLib)

UniLayout is a project to make multi-platform development easier for iOS and Android regarding layouts. The goal is to have a uniform layout system to port the flexibility of Android layouts to iOS while adding more features to Android. Based on the layout container system from Android (like LinearLayout and FrameLayout).


### Features

* Ports the Android layout capabilities to iOS, including Linear Layout, Frame Layout and Scroll View
* For iOS, the scroll view automatically updates its content size
* Adds additional capabilities like minimum and maximum sizes and more flexibility in alignment (through gravity)


### iOS integration guide

The library is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile.

```ruby
pod "UniLayout", '~> 0.2.1'
```


### Android integration guide

When using gradle, the library can easily be imported into the build.gradle file of your project. Add the following dependency:

```
compile 'com.crescentflare.unilayout:UniLayoutLib:0.2.1'
```

Make sure that jcenter is added as a repository.


### Example

The provided example shows how to build several layout styles. The layout is written in code on iOS, or xml files on Android.


### Status

The library is in its initial state but has basic functionality which can already be useful. However, code isn't optimized yet and may contain bugs. Code optimizations and more features will be added in the future.
