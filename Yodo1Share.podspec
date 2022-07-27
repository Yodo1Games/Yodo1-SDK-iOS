Pod::Spec.new do |s|
  s.name             = 'Yodo1Share'
  s.version          = '6.1.3'
  s.summary          = 'A short description of Yodo1Share.'
  
  s.description      = <<-DESC
  TODO: Add long description of the pod here.
  DESC
  
  s.homepage         = 'https://github.com'
  
  s.author           = { 'yixian huang' => 'huangyixian@yodo1.com' }
  s.source           = { :git => 'https://github.com/Yodo1Games/Yodo1-SDK-iOS.git', :tag => "#{s.name}#{s.version}" }
  
  
  s.ios.deployment_target = '9.0'
  
  s.vendored_libraries = ["*.a"]
  
  s.source_files = ["*.h"]
  
  s.public_header_files = ["*.h"]
  
  s.resources = ["*.bundle", "*.{m,mm}"]
  
#  s.vendored_frameworks = ["Yodo1Share/libs/Tencent/TencentOpenAPI.framework"]
  
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
  
  s.dependency 'Yodo1Commons','6.1.1'
  s.dependency 'Yodo1QQSDK','6.1.0'
  s.dependency 'FBSDKShareKit','12.3.2'
  s.dependency 'Weibo_SDK','3.3.0'#'Yodo1WeiboSDK', '5.0.0'
  s.dependency 'WechatOpenSDK', '1.8.7.1'#'Yodo1WeChatSDK', '5.0.0'

end

