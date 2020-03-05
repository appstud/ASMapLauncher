![CocoaPods Compatible](https://img.shields.io/badge/pod-v1.0.0-blue)
![Platform](https://img.shields.io/badge/platform-iOS-lightgrey)
![License](https://img.shields.io/badge/license-MIT-brightgreen)

# AppstudMapLauncher
AppstudMapLauncher is a library for iOS written in Swift that helps navigation with various mapping applications.

## Requirements

| AppstudMapLauncher Version | Minimum iOS Target  | Swift Version |
|:--------------------:|:---------------------------:|:---------------------------:|
| 1.0.7 | 9.x | 4.2 |
| 1.0.6 | 8.x | 4.0 |
| 1.0.5 | 8.0 | 3.x |

## CocoaPods

CocoaPods is a dependency manager for Cocoa projects. You can install it with the following command:
```	
$ gem install cocoapods
```
To integrate AppstudMapLauncher into your Xcode project using CocoaPods, specify it in your Podfile:
```
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

target '<Your Target Name>' do
	pod 'AppstudMapLauncher', '1.0.7'
end
```
Then, run the following command:
```
$ pod install
```

## Usage

First initiate AppstudMapLauncher and check for a selected mapping application that installed on device
```
let mapLauncher = AppstudMapLauncher()
let isInstalled = mapLauncher.isMapAppInstalled(.here)
```

Then, launch selected mapping application
```
if isInstalled {
	let destination: CLLocation! = CLLocation(latitude: 41.0053215, longitude: 29.0121795)
	let fromMapPoint: MapPoint! = MapPoint(location: CLLocation(latitude: currenctCoordinate.latitude,
	longitude: currenctCoordinate.longitude),
										   name: "", 
										   address: "")
    let toMapPoint: MapPoint! = MapPoint(location: CLLocation(latitude: destination.coordinate.latitude, longitude: destination.coordinate.longitude), 
                                         name: "", 
                                         address: "")
    mapLauncher.launchMapApp(.here, 
                             fromDirections: fromMapPoint, 
                             toDirection: toMapPoint)
}

```
Supported mapping applications
```
- Apple Maps
- HERE Maps
- Google Maps
- Yandex Navigator
- Citymapper
- Navigon
- The Transit App
- Waze
- Moovit
```	

## MIT License
```
Copyright (c) 2020 Appstud

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
