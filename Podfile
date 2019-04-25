@MAPS_SDK_VERSION = '4.11.0-beta.1'
platform :ios, '9.3'

target 'treble' do
    pod 'Mapbox-iOS-SDK', "~> #{@MAPS_SDK_VERSION}"
    #pod 'Mapbox-iOS-SDK-stripped', :podspec => "https://raw.githubusercontent.com/mapbox/mapbox-gl-native/ios-v#{@MAPS_SDK_VERSION}/platform/ios/Mapbox-iOS-SDK-stripped.podspec"

    pod 'Crashlytics', '~> 3.8'
    pod 'GoogleMaps', '~> 3.0'
    pod 'NSTimeZone-Coordinate', '~> 1.0'

    script_phase :name => "Copy bitcode symbol maps into Products directory",
        :script => "if [ \"$ACTION\" = \"install\" ]; then mdfind -name .bcsymbolmap -onlyin \"${PODS_ROOT}\" | xargs -I{} cp -v {} \"${CONFIGURATION_BUILD_DIR}\"; fi;",
        :execution_position => :after_compile
end
