Pod::Spec.new do |s|
  s.name             = 'Yodo1OnlineParameter'
  s.version          = '6.1.5'
  s.summary          = 'The online parameter SDK for iOS'
  
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
    #        "ENABLE_BITCODE" => "NO",
    "VALID_ARCHS": "armv7 arm64",
    "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
    "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
  }
  
  s.frameworks = [
  'CoreTelephony',
  'CoreLocation',
  'MobileCoreServices',
  'SystemConfiguration',
  'Security',
  ]
  
  s.weak_frameworks = [
  'AdSupport',
  'SafariServices',
  ]
  
  s.libraries = [
  'sqlite3.0',
  'c++',
  'z']
  s.dependency 'Yodo1Commons','~>6.1.5'
  
end
