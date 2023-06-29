Pod::Spec.new do |s|
  s.name             = 'Yodo1Suit'
  s.version          = '6.3.1'
  s.summary          = 'The Yodo1 Suit SDK for iOS'
  
  s.description      = <<-DESC
  TODO: Add long description of the pod here.
  DESC
  
  s.homepage         = 'https://www.yodo1.com/'
  s.author           = { 'Yodo1Games' => 'devadmin@yodo1.com' }
  s.source           = { :git => 'https://github.com/Yodo1Games/Yodo1-SDK-iOS.git', :tag => "#{s.name}#{s.version}" }
  
  s.ios.deployment_target = '11.0'
  
  s.subspec 'Yodo1_Suit' do |ss|
    ss.source_files = s.name + '/Classes/**/*'
    ss.public_header_files = s.name + '/Classes/**/*.h'
    ss.resource = s.name + '/Assets/**/*.bundle'
    
    ss.requires_arc = true
    
    ss.xcconfig = {
      'OTHER_LDFLAGS' => '-ObjC',
      "VALID_ARCHS": "armv7 arm64",
      "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
      "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
    }
    
    ss.frameworks = [
    'Foundation',
    'UIKit',
    'Security',
    ]
    
    ss.weak_frameworks = [
    'AdSupport',
    'SafariServices',
    ]
    
    ss.libraries = [
    'sqlite3.0',
    'c++',
    'z']
    
    ss.dependency 'Yodo1Analytics/Core','6.3.1'
    ss.dependency 'Yodo1Commons','6.1.6'
    ss.dependency 'Yodo1OnlineParameter','6.1.5'
    ss.dependency 'Yodo1UCenter','6.3.1'
  end
  
  s.subspec 'Yodo1_UA_Adjust' do |ss|
    ss.xcconfig = {
      'OTHER_LDFLAGS' => '-ObjC',
      "VALID_ARCHS": "armv7 arm64",
      "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
      "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
    }
    ss.dependency 'Yodo1Analytics/Adjust','6.3.1'
    ss.dependency 'Yodo1Suit/Yodo1_Suit',"#{s.version}"
  end
  
  s.subspec 'Yodo1_UA_AppsFlyer' do |ss|
    ss.xcconfig = {
      'OTHER_LDFLAGS' => '-ObjC',
      "VALID_ARCHS": "armv7 arm64",
      "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
      "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
    }
    ss.dependency 'Yodo1Analytics/AppsFlyer','6.3.1'
    ss.dependency 'Yodo1Suit/Yodo1_Suit',"#{s.version}"
  end
  
  s.subspec 'Yodo1_UnityConfigKey' do |ss|
    ss.xcconfig = {
      "GCC_PREPROCESSOR_DEFINITIONS" => 'UNITY_PROJECT',
      'OTHER_LDFLAGS' => '-ObjC',
      "VALID_ARCHS": "armv7 arm64",
      "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
      "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
    }
    ss.dependency 'Yodo1iCloud','6.1.4'
    ss.dependency 'Yodo1GameCenter','6.3.1'
    ss.dependency 'Yodo1iRate','6.1.1'
    ss.dependency 'Yodo1Replay','6.1.4'
    ss.dependency 'Yodo1Notification','6.1.4'
    ss.dependency 'Yodo1Suit/Yodo1_Suit',"#{s.version}"
  end
  
  s.subspec 'Yodo1_Purchase' do |ss|
    ss.xcconfig = {
      "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_UCCENTER',
      'OTHER_LDFLAGS' => '-ObjC',
      "VALID_ARCHS": "armv7 arm64",
      "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
      "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
    }
    ss.dependency 'Yodo1Purchase','6.3.1'
    ss.dependency 'Yodo1Suit/Yodo1_Suit',"#{s.version}"
  end
  
  s.subspec 'Yodo1_GameCenter' do |ss|
    ss.xcconfig = {
      "GCC_PREPROCESSOR_DEFINITIONS" => 'GAMECENTER',
      'OTHER_LDFLAGS' => '-ObjC',
      "VALID_ARCHS": "armv7 arm64",
      "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
      "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
    }
    ss.dependency 'Yodo1GameCenter','6.3.1'
    ss.dependency 'Yodo1Suit/Yodo1_Suit',"#{s.version}"
  end
  
  s.subspec 'Yodo1_iCloud' do |ss|
    ss.xcconfig = {
      "GCC_PREPROCESSOR_DEFINITIONS" => 'ICLOUD',
      'OTHER_LDFLAGS' => '-ObjC',
      "VALID_ARCHS": "armv7 arm64",
      "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
      "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
    }
    ss.dependency 'Yodo1iCloud','6.1.4'
    ss.dependency 'Yodo1Suit/Yodo1_Suit',"#{s.version}"
  end
  
  s.subspec 'Yodo1_iRate' do |ss|
    ss.xcconfig = {
      "GCC_PREPROCESSOR_DEFINITIONS" => 'IRATE',
      'OTHER_LDFLAGS' => '-ObjC',
      "VALID_ARCHS": "armv7 arm64",
      "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
      "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
    }
    ss.dependency 'Yodo1iRate','6.1.1'
    ss.dependency 'Yodo1Suit/Yodo1_Suit',"#{s.version}"
  end
  
  s.subspec 'Yodo1_Notification' do |ss|
    ss.xcconfig = {
      "GCC_PREPROCESSOR_DEFINITIONS" => 'NOTIFICATION',
      'OTHER_LDFLAGS' => '-ObjC',
      "VALID_ARCHS": "armv7 arm64",
      "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
      "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
    }
    ss.dependency 'Yodo1Notification','6.1.4'
    ss.dependency 'Yodo1Suit/Yodo1_Suit',"#{s.version}"
  end
  
  s.subspec 'Yodo1_Replay' do |ss|
    ss.xcconfig = {
      "GCC_PREPROCESSOR_DEFINITIONS" => 'REPLAY',
      'OTHER_LDFLAGS' => '-ObjC',
      "VALID_ARCHS": "armv7 arm64",
      "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
      "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
    }
    ss.dependency 'Yodo1Replay','6.1.4'
    ss.dependency 'Yodo1Suit/Yodo1_Suit',"#{s.version}"
  end
  
  #s.subspec 'Yodo1_Share' do |ss|
  #    ss.xcconfig = {
  #        "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_SHARE',
  #        'OTHER_LDFLAGS' => '-ObjC',
  #        "VALID_ARCHS": "armv7 arm64",
  #        "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
  #        "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
  #    }
  #    ss.dependency 'Yodo1Share','6.1.6'
  #    ss.dependency 'Yodo1Suit/Yodo1_Suit',"#{s.version}"
  #end
  
  
end
