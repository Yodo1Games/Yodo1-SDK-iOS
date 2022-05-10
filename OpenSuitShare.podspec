Pod::Spec.new do |s|
  s.name             = 'OpenSuitShare'
  s.version          = '0.0.1'
  s.summary          = 'A short description of Yodo1Share.'
  
  s.description      = <<-DESC
  TODO: Add long description of the pod here.
  DESC
  
  s.homepage         = 'https://github.com'
  
  s.license          = { :type => 'MIT', :file => "LICENSE" }
  s.author           = { 'yixian huang' => 'huangyixian@yodo1.com' }
  s.source           = { :git => 'https://github.com/Yodo1Games/Yodo1-SDK-iOS.git', :tag => "#{s.name}#{s.version}" }
  
  
  s.ios.deployment_target = '9.0'

  s.vendored_libraries = ["OpenSuitShare/*.a"]
  
  s.source_files = ["OpenSuitShare/**/*.{h,m,mm}"]
  
  s.public_header_files = ["OpenSuitShare/**/*.h"]
  
  s.resources = ["*.bundle"]
  
#  s.vendored_frameworks = ["Yodo1Share/libs/Tencent/TencentOpenAPI.framework"]
  
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
  
  s.dependency 'Yodo1OnlineParameter','6.0.5'
  s.dependency 'Yodo1Qrencode','5.0.0'
  s.dependency 'Yodo1QQSDK','5.0.2'
  s.dependency 'Yodo1FBSDKShareKit','5.0.1'
  s.dependency 'Weibo_SDK','3.3.0'
  s.dependency 'WechatOpenSDK', '1.8.7.1'

end

