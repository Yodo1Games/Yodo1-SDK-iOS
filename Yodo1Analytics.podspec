Pod::Spec.new do |s|
  s.name             = 'Yodo1Analytics'
  s.version          = '6.3.0'
  s.summary          = 'The Yodo1 Analytics SDK for iOS'
  
  s.description      = <<-DESC
  TODO: Add long description of the pod here.
  DESC
  
  s.homepage         = 'https://www.yodo1.com/'
  s.author           = { 'Yodo1Games' => 'devadmin@yodo1.com' }
  s.source           = { :git => 'https://github.com/Yodo1Games/Yodo1-SDK-iOS.git', :tag => "#{s.name}#{s.version}" }
  
  s.ios.deployment_target = '11.0'
  s.requires_arc = true
  
  s.xcconfig = {
    'OTHER_LDFLAGS' => '-ObjC',
    "VALID_ARCHS": "armv7 arm64",
    "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
    "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
  }
  
  s.frameworks = [
  'Foundation',
  'UIKit',
  'SystemConfiguration',
  'CoreGraphics',
  'Security',
  'CoreTelephony'
  ]
  
  s.weak_frameworks = []
  
  s.libraries = [
  'sqlite3.0',
  'c++',
  'z',
  ]
  
  s.dependency 'Yodo1Commons','~>6.1.6'
  
  s.subspec 'Core' do |sub|
    sub.source_files = s.name + '/Classes/Core/**/*'
    sub.public_header_files = s.name + '/Classes/Core/**/*.h'
    
    sub.dependency 'ThinkingSDK','2.8.3.2'
  end
  
  s.subspec 'AppsFlyer' do |sub|
    sub.source_files = s.name + '/Classes/AppsFlyer/**/*'
    sub.public_header_files = s.name + '/Classes/AppsFlyer/**/*.h'
    sub.dependency 'AppsFlyerFramework', '6.7.0'
    sub.frameworks = [
    'SystemConfiguration',
    'Security',
    'CoreTelephony',
    'iAd',
    'AdSupport',
    'AdServices',
    'AppTrackingTransparency'
    ]
  end
  
  s.subspec 'Adjust' do |sub|
    sub.source_files = s.name + '/Classes/Adjust/**/*'
    sub.public_header_files = s.name + '/Classes/Adjust/**/*.h'
    sub.dependency 'Adjust', '4.33.4'
    sub.frameworks = [
    'AdSupport',
    'AdServices',
    'StoreKit',
    'AppTrackingTransparency'
    ]
  end
end
