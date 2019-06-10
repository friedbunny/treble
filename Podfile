@MAPS_SDK_VERSION = '5.1.0-alpha.2'
deploymentTarget = '9.3'
platform :ios, deploymentTarget

target 'treble' do
    pod 'Mapbox-iOS-SDK', "#{@MAPS_SDK_VERSION}"
    #pod 'Mapbox-iOS-SDK-stripped', :podspec => "https://raw.githubusercontent.com/mapbox/mapbox-gl-native/ios-v#{@MAPS_SDK_VERSION}/platform/ios/Mapbox-iOS-SDK-stripped.podspec"

    pod 'Crashlytics', '~> 3.8'
    pod 'GoogleMaps', '~> 3.0'
    pod 'NSTimeZone-Coordinate', '~> 1.0'
end

# Force the pod targets into using the same deployment target as the app.
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = deploymentTarget
      if config.name != "Debug" then
        config.build_settings['LLVM_LTO'] = 'YES'
      end
    end
  end
end
