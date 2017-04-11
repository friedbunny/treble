# Treble

[![Build Status](https://www.bitrise.io/app/3b92313af6737ed9.svg?token=x_5gc7w21RhLrN0JYxk7iA&branch=master)](https://www.bitrise.io/app/3b92313af6737ed9)

[Mapbox iOS SDK](https://github.com/mapbox/mapbox-gl-native) comparison app, featuring [Apple MapKit](https://developer.apple.com/library/ios/documentation/MapKit/Reference/MapKit_Framework_Reference/), [Google Maps for iOS](https://developers.google.com/maps/documentation/ios-sdk/), and [Mapzen Tangram-es](https://github.com/tangrams/tangram-es).

![Treble](https://cloud.githubusercontent.com/assets/1198851/7792550/1f208ad4-0269-11e5-8156-f3b7de4f32aa.gif)

## Usage

- Keep tapping the selected tab to switch styles.
- Swipe on the bottom tab bar to switch providers.
- Tap the top status bar to recenter the map on your location.

## URL scheme

To load a Mapbox map in Treble at a particular location, you can use this URL scheme in by entering it in Mobile Safari, sending it to your mobile device via AirDrop/Slack/etc., or implementing it in your iOS app:

`treble://?lat=40.73&lng=-73.94&zoom=10`

### Supported query parameters

 * `lat`: set the map latitude
 * `lng`: set the map longitude
 * `zoom`: set the map zoom level (`0` being the whole world)
 * `bearing`: set the map bearing in degrees clockwise from due north
 * `pitch`: set the map pitch (`0` looking directly overhead, `60` being maximum tilt)
