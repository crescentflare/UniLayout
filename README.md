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
* Adds a new margin property to be used between views, this will be ignored if it's the first view that's set to visible or invisible
* For iOS, the linear and frame containers also have built-in support for taps and highlighting
* For Android, there is a custom reusing container which can be used as an alternative for the recycler view, includes standard support for selection and swiping
* Provides a textview fix for Android, to have a correct measure result when having multiple lines


### iOS integration guide

The library is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod "UniLayout", '~> 0.4.1'
```

The above version is for Swift 4.2. For older Swift versions use the following:
- Swift 4.1: UniLayout 0.4.0
- Swift 4.0: UniLayout 0.3.8
- Swift 3: UniLayout 0.3.7


### Android integration guide

When using gradle, the library can easily be imported into the build.gradle file of your project. Add the following dependency:

```
compile 'com.crescentflare.unilayout:UniLayoutLib:0.4.0'
```

Make sure that jcenter is added as a repository.


### Example

The provided example shows how to build several layout styles. The layout is written in code on iOS, or xml files on Android.


### More information

Refer to the [wiki](https://github.com/crescentflare/UniLayout/wiki) for more detailed information about the library.


### Status

The library is in its initial state but has basic functionality which can already be useful. However, code isn't optimized yet and may contain bugs. Code optimizations and more features will be added in the future.
