platform :ios, '9.3'

target 'treble' do
    #pod 'Mapbox-iOS-SDK', '~> 4.0.0'
    pod 'Mapbox-iOS-SDK-symbols', :podspec => 'https://raw.githubusercontent.com/mapbox/mapbox-gl-native/ios-v4.2.0-alpha.2/platform/ios/Mapbox-iOS-SDK-symbols.podspec'

    pod 'Crashlytics', '~> 3.8'
    pod 'GoogleMaps', '~> 2.0'
    pod 'NSTimeZone-Coordinate', '~> 1.0'

    script_phase :name => "Copy bitcode symbol maps into Products directory",
        :script => "if [ \"$ACTION\" = \"install\" ]; then mdfind -name .bcsymbolmap -onlyin \"${PODS_ROOT}\" | xargs -I{} cp -v {} \"${CONFIGURATION_BUILD_DIR}\"; fi;",
        :execution_position => :after_compile
end
