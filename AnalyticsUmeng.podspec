Pod::Spec.new do |s|
  s.name             = 'AnalyticsUmeng'
  s.version          = '6.0.7'
  s.summary          = 'v7.2.4+G-->v7.3.3+G;添加UAPM crash 库，UMDevice v2.1.0,UMAPM v1.5.6'
  
  s.description      = <<-DESC
  TODO: Add long description of the pod here.
  DESC
  
  s.homepage         = 'https://github.com'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => "LICENSE" }
  s.author           = { 'yixian huang' => 'huangyixian@yodo1.com' }
  s.source           = { :git => 'https://github.com/Yodo1Games/Yodo1-SDK-iOS.git', :tag => "#{s.name}#{s.version}" }
  
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  
  s.ios.deployment_target = '9.0'
  
  s.source_files = [ "*.{h,m}" ]
  
  s.public_header_files = [ "*.h"]
  
  # s.vendored_libraries = [ "*.a" ]
  
  s.requires_arc = true
  
  s.xcconfig = {
    'OTHER_LDFLAGS' => '-ObjC',
    'ENABLE_BITCODE' => "NO",
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
  'Twitter',
  'WebKit',
  'SystemConfiguration',
  'AudioToolbox',
  'Security',
  'CoreBluetooth']
  
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
  
  s.dependency 'Yodo1ThirdsAnalytics','6.1.1'
  #由原来的UMCCommon变为UMCommon
  s.dependency 'UMCommon', '7.3.5'
  s.dependency 'UMAnalyticsGame', '7.3.5+G'
  ##############################################
  s.dependency 'UMDevice','2.1.0'
  s.dependency 'UMCCommonLog', '2.0.2'
  s.dependency 'UMAPM', '1.5.6'
end
