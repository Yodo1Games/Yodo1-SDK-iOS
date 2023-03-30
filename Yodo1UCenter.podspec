Pod::Spec.new do |s|
  s.name             = 'Yodo1UCenter'
  s.version          = '1.0.3'
  s.summary          = 'Yodo1UCenter'
  
  s.description      = <<-DESC
  TODO: Add long description of the pod here.
  DESC
  
  s.homepage         = 'https://www.yodo1.com/'
  s.author           = { 'Yodo1Games' => 'devadmin@yodo1.com' }
  s.source           = { :git => 'https://github.com/Yodo1Games/Yodo1-SDK-iOS.git', :tag => "#{s.name}#{s.version}" }
  
  s.ios.deployment_target = '10.0'
  
  s.source_files = s.name + '/Classes/**/*'
  s.public_header_files = s.name + '/Classes/**/*.h'
  
  s.requires_arc = true
  
  s.xcconfig = {
    'OTHER_LDFLAGS' => '-ObjC',
    "VALID_ARCHS": "armv7 arm64",
    "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
    "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
  }
  
  s.frameworks = [
  'Accounts', 
  'AssetsLibrary',
  'AVFoundation', 
  'CoreTelephony',
  'CoreLocation', 
  'CoreMotion',
  'CoreMedia',
  'EventKit',
  'EventKitUI', 
  'iAd', 
  'ImageIO',
  'MobileCoreServices',
  'MediaPlayer',
  'MessageUI',
  'MapKit',
  'Social',
  'StoreKit',
  'WebKit',
  'SystemConfiguration',
  'AudioToolbox',
  'Security']
  
  s.weak_frameworks = [
  'AdSupport',
  'SafariServices',
  'ReplayKit',
  'CloudKit',
  'GameKit']
  
  s.libraries = [
  'sqlite3.0',
  'c++',
  'z']
  
  s.dependency 'Yodo1Commons','~>6.1.4'
  
end
