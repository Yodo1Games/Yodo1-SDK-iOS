Pod::Spec.new do |s|
    s.name             = 'Yodo1AntiAddiction'
    s.version          = '6.0.6'
    s.summary          = '防沉迷3.0，修复bug/添加控制游客开关功能/提升版本号
                          修改客户端文案，更新2022年节假日列表'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com'
    
    s.license          = { :type => 'MIT', :file => "LICENSE" }
    
    s.author           = { 'Yodo1Games' => 'devadmin@yodo1.com' }
    
    s.source           = { :git => 'https://github.com/Yodo1Games/Yodo1-SDK-iOS.git', :tag => "#{s.name}#{s.version}" }

  s.ios.deployment_target = '9.0'

  s.source_files = 'Yodo1AntiAddiction/Classes/**/*'
  s.public_header_files = 'Yodo1AntiAddiction/Classes/**/*.h'

  # 用于解决Unity2019.3.0(包含2019.3.0)以上无法读取问题，Unity会添加CCopy资源脚本
  s.resource_bundles = {
    'Yodo1AntiAddictionResource' => ['Yodo1AntiAddiction/Assets/*']
  }

  # 用于解决Unity2019.3.0(不包含2019.3.0)以下以及native原生资源无法读取问题
  s.resources = 'Yodo1AntiAddiction/Assets/*.png'

    s.requires_arc = true
  
  s.xcconfig = {
      "OTHER_LDFLAGS" => "-ObjC",
      "VALID_ARCHS": "armv7 arm64",
      "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
      "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
  }

    s.frameworks = 'Accounts', 'AssetsLibrary','AVFoundation', 'CoreTelephony','CoreLocation', 'CoreMotion' ,'CoreMedia', 'EventKit','EventKitUI', 'iAd', 'ImageIO','MobileCoreServices', 'MediaPlayer' ,'MessageUI','MapKit','Social','StoreKit','WebKit','SystemConfiguration','AudioToolbox','Security','CoreBluetooth'
  s.weak_frameworks = 'AdSupport','SafariServices','ReplayKit','CloudKit','GameKit'
  s.libraries = 'sqlite3', 'z'
  s.compiler_flags = '-Dunix'

  s.dependency 'Yodo1OnlineParameter'
  s.dependency 'Yodo1Commons'
  s.dependency 'Yodo1Purchase'
  s.dependency 'TPKeyboardAvoiding'
  s.dependency 'FMDB'
  s.dependency 'Masonry'
  
end
