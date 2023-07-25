Pod::Spec.new do |s|
  s.name             = 'Yodo1Share'
  s.version          = '1.0.3'
  s.summary          = 'Yodo1 Sharing SDK for iOS'
  
  s.description      = <<-DESC
  TODO: Add long description of the pod here.
  DESC
  
  s.homepage         = 'https://www.yodo1.com/'
  s.author           = { 'Yodo1Games' => 'devadmin@yodo1.com' }
  s.source           = { :git => 'https://github.com/Yodo1Games/Yodo1-SDK-iOS.git', :tag => "#{s.name}#{s.version}" }
  
  s.ios.deployment_target = '12.0'
  
  s.requires_arc = true
  s.xcconfig = {
    "OTHER_LDFLAGS" => "-ObjC",
    "GENERATE_INFOPLIST_FILE" => "YES"
  }
  s.pod_target_xcconfig = {
    "DEFINES_MODULE" => "YES",
    "VALID_ARCHS" => "arm64 arm64e armv7 armv7s x86_64",
    "VALID_ARCHS[sdk=iphoneos*]" => "arm64 arm64e armv7 armv7s",
    "VALID_ARCHS[sdk=iphonesimulator*]" => "x86_64 arm64"
  }
  s.libraries = [ 'sqlite3.0', 'c++', 'z', 'iconv']
  
  s.frameworks = ['UIKit','Foundation','CoreFoundation','QuartzCore','SystemConfiguration','MobileCoreServices','CoreServices','CoreTelephony','Security', 'Social']
  s.weak_frameworks = [ 'AdSupport' ]
  
  s.subspec 'Core' do |sub|
    sub.source_files = s.name + '/Core/Classes/**/*'
    sub.public_header_files = s.name + '/Core/Classes/**/*.h'
    sub.resource = s.name + '/Core/Assets/**/*.bundle'
    
    sub.dependency 'Yodo1Suit/Base'
  end
  
  s.subspec 'Facebook' do |sub|
    sub.source_files = s.name + '/Facebook/Classes/**/*'
    sub.public_header_files = s.name + '/Facebook/Classes/**/*.h'
    
    sub.dependency 'Yodo1Share/Core', "#{s.version}"
    sub.dependency 'FBSDKShareKit','12.3.2'
  end
  
  s.subspec 'QQ' do |sub|
    sub.source_files = s.name + '/QQ/Classes/**/*'
    sub.public_header_files = s.name + '/QQ/Classes/**/*.h'
    sub.resource = s.name + '/QQ/Assets/**/*.bundle'
    sub.vendored_frameworks = s.name + '/QQ/Lib/**/*.framework', s.name + '/QQ/Lib/**/*.xcframework'
    
    sub.dependency 'Yodo1Share/Core', "#{s.version}"
  end
  
  s.subspec 'SinaWeibo' do |sub|
    sub.source_files = s.name + '/SinaWeibo/Classes/**/*'
    sub.public_header_files = s.name + '/SinaWeibo/Classes/**/*.h'
    
    sub.dependency 'Yodo1Share/Core', "#{s.version}"
    sub.dependency 'Weibo_SDK','3.3.0'
  end
  
  s.subspec 'Wechat' do |sub|
    sub.source_files = s.name + '/Wechat/Classes/**/*'
    sub.public_header_files = s.name + '/Wechat/Classes/**/*.h'
    
    sub.dependency 'Yodo1Share/Core', "#{s.version}"
    sub.dependency 'WechatOpenSDK', '1.8.7.1'
  end
  
end

