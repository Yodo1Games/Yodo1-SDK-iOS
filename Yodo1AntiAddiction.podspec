Pod::Spec.new do |s|
  s.name             = 'Yodo1AntiAddiction'
  s.version          = '3.2.11'
  s.summary          = 'Yodo1 Anti-Addiction SDK for iOS'
  s.description      = <<-DESC
  TODO: Add long description of the pod here.
  DESC
  
  s.license          = { :type => 'MIT', :file => "LICENSE" }
  
  s.homepage         = 'https://www.yodo1.com/'
  s.author           = { 'Yodo1Games' => 'devadmin@yodo1.com' }
  s.source           = { :git => 'https://github.com/Yodo1Games/Yodo1-SDK-iOS.git', :tag => "#{s.name}#{s.version}" }
  
  s.ios.deployment_target = '11.0'
  
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
  
  s.frameworks = 'CoreTelephony','CoreLocation','MobileCoreServices','SystemConfiguration','Security'
  s.weak_frameworks = 'AdSupport','SafariServices'
  s.libraries = 'sqlite3', 'z'
  s.compiler_flags = '-Dunix'
  
  s.dependency 'TPKeyboardAvoiding'
  s.dependency 'FMDB'
  s.dependency 'Masonry'
  
  #  s.dependency 'Yodo1Commons'
  #  s.dependency 'Yodo1UCenter'
  #
  s.dependency 'Yodo1Suit/Base'
  s.dependency 'Yodo1Suit/UCenter'
end