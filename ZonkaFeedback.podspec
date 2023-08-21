Pod::Spec.new do |spec|
  spec.name         = 'ZonkaFeedback'
  spec.version      = '1.2'
  spec.license      = { :type => "MIT", :file => "LICENSE.txt" }
  spec.summary      = 'ZonkaFeedback SDK is a simple and easy to use SDK to collect user responses with in an iOS application'
  spec.homepage     = 'https://zonkafeedback.com/'
  spec.author       = 'Peeka Sharma'
  spec.source =  { :git => 'https://github.com/zonka-feedback/ios-sdk.git'}
  spec.requires_arc = true
  spec.static_framework = false
  spec.ios.deployment_target = '12.0'
  spec.swift_version = "5"
  spec.xcconfig = { 'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES' }
  spec.source_files = 'ZonkaFeedbackSDK/ZonkaFeedback/**/*.{swift}'
  spec.preserve_paths = 'ZonkaFeedbackSDK/ZonkaFeedback/*'
  spec.resources = 'ZonkaFeedbackSDK/ZonkaFeedback/*.{png}'
end
