# Uncomment the next line to define a global platform for your project
platform :ios, '14.0'

target 'Messenger_2' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Messenger_2
pod 'Firebase/Analytics', '~> 6.33.0'
pod 'Firebase/Core'
pod 'Firebase/Auth'
pod 'Firebase/Database'
pod 'Firebase/Storage'

#Google
pod 'GoogleSignIn'

pod 'MessageKit'
pod 'JGProgressHUD'
pod 'RealmSwift', '~> 5.0.2'
pod 'SDWebImage'


pod "RxSwift"
pod "RxCocoa"

  target 'Messenger_2Tests' do
    inherit! :search_paths
    # Pods for testing
  end

end

post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
    config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
  end
end
