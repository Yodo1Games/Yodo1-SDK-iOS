Pod::Spec.new do |s|
  s.name             = 'Yodo1Commons'
  s.version          = '6.1.5'
  s.summary          = 'The Core Kit for iOS'
  
  s.description      = <<-DESC
  TODO: Add long description of the pod here.
  DESC
  
  s.homepage         = 'https://www.yodo1.com/'
  s.author           = { 'Yodo1Games' => 'devadmin@yodo1.com' }
  s.source           = { :git => 'https://github.com/Yodo1Games/Yodo1-SDK-iOS.git', :tag => "#{s.name}#{s.version}" }
  
  s.ios.deployment_target = '11.0'
  
  s.source_files = s.name + '/Classes/**/*'
  s.public_header_files = s.name + '/Classes/**/*.h'
  
  s.requires_arc = true
  
  s.xcconfig = {
    "OTHER_LDFLAGS" => "-ObjC",
    "VALID_ARCHS": "armv7 arm64",
    "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
    "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
  }
  
  s.frameworks = [
  'UIKit',
  'Foundation',
  'CoreFoundation',
  'QuartzCore',
  'SystemConfiguration',
  'MobileCoreServices',
  'CoreServices',
  'CoreTelephony',
  'Security',
  ]
  
  s.weak_frameworks = [
  'AdSupport',
  ]

  s.libraries = [
  'sqlite3.0',
  'c++',
  'z',
  ]
  
end
