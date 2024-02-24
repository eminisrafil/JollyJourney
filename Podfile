platform :ios, '14.4'

target 'TravelHacker' do
  use_frameworks!
  inherit! :search_paths

  pod 'PopBounceButton'
  pod 'Shuffle-iOS'
  pod 'Kingfisher'
  pod 'Kingfisher/SwiftUI'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
#      if config.name == 'Debug'
#        config.build_settings['OTHER_SWIFT_FLAGS'] = ['$(inherited)', '-Onone']
#        config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Owholemodule'
#      end
#
#      Only add the below line if runnign on m1 mac simulator
#      https://stackoverflow.com/questions/72529517/building-for-ios-simulator-but-linking-in-object-file-built-for-ios-in-xcode
        config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
        xcconfig_path = config.base_configuration_reference.real_path
        xcconfig = File.read(xcconfig_path)
        xcconfig_mod = xcconfig.gsub(/DT_TOOLCHAIN_DIR/, "TOOLCHAIN_DIR")
        File.open(xcconfig_path, "w") { |file| file << xcconfig_mod }
    end
  end
end
