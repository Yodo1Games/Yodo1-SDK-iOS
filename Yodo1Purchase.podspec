Pod::Spec.new do |s|
  s.name             = 'Yodo1Purchase'
  s.version          = '6.3.0'
  s.summary          = 'In-App purchase SDK for iOS'
  
  s.description      = <<-DESC
  TODO: Add long description of the pod here.
  DESC
  
  s.homepage         = 'https://www.yodo1.com/'
  s.author           = { 'Yodo1Games' => 'devadmin@yodo1.com' }
  s.source           = { :git => 'https://github.com/Yodo1Games/Yodo1-SDK-iOS.git', :tag => "#{s.name}#{s.version}" }
  
  s.ios.deployment_target = '11.0'
  
  s.source_files = s.name + '/Classes/**/*'
  s.public_header_files = s.name + '/Classes/**/*.h'
  s.resource = s.name + '/Assets/**/*.bundle'
  
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
  'CoreTelephony',
  'CoreLocation', 
  'ImageIO',
  'MobileCoreServices',
  'StoreKit',
  'WebKit',
  'SystemConfiguration',
  'Security']
  
  s.weak_frameworks = [
  'AdSupport',
  'SafariServices'
  ]
  
  s.libraries = [
  'sqlite3.0',
  'c++',
  'z']
  
  s.dependency 'Yodo1Commons','~>6.1.6'
  s.dependency 'Yodo1Analytics/Core','6.3.0'
  s.dependency 'Yodo1UCenter','6.3.0'
  
end
