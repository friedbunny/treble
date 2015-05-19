# Treble

A [Mapbox GL for iOS](https://github.com/mapbox/mapbox-gl-native) demo app, featuring [Apple MapKit](https://developer.apple.com/library/ios/documentation/MapKit/Reference/MapKit_Framework_Reference/) and [Google Maps for iOS](https://developers.google.com/maps/documentation/ios/).

![Treble](https://cloud.githubusercontent.com/assets/1198851/7528109/5b3810d0-f4d8-11e4-9e46-589a50e29bd3.gif)

## Getting started

Treble is still extremely rough and development continues apace. If you want to try it out now, here’s what to do:

1. `git clone https://github.com/friedbunny/treble.git`
1. `cd treble && pod install`
1. `cp treble/APIKeys.EXAMPLE.plist treble/APIKeys.plist`
1. Add your [Mapbox access token](https://www.mapbox.com/developers/api/#access-tokens) and [Google API key](https://developers.google.com/maps/documentation/ios/start#the_google_maps_api_key) to `APIKeys.plist`
1. Open `Treble.xcworkspace` in Xcode and build it for your device or simulator

## Usage

Keep tapping the selected tab to switch styles.

## Known issues

* Controls are minimal/missing
* Uses a [custom fork of Mapbox GL](https://github.com/friedbunny/mapbox-gl-native/tree/treble) that closely tracks `master`
  * Run `pod update` frequently as releases are happening rather often (daily) right now

## Contributing

Please feel free to toss tickets at this repo: report bugs, submit pull requests, add missing design assets, suggest features, say hello, offer money, and so on.
