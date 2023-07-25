Pod::Spec.new do |s|
  s.name             = 'Yodo1Suit'
  s.version          = '6.3.2'
  s.summary          = 'The Yodo1 Suit SDK for iOS'
  
  s.description      = <<-DESC
  TODO: Add long description of the pod here.
  DESC
  
  s.homepage         = 'https://www.yodo1.com/'
  s.author           = { 'Yodo1Games' => 'devadmin@yodo1.com' }
  s.source           = { :git => 'https://github.com/Yodo1Games/Yodo1-SDK-iOS.git', :tag => "#{s.name}#{s.version}" }
  
  s.ios.deployment_target = '11.0'
  
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
  s.libraries = [ 'sqlite3.0', 'c++', 'z']
  
  s.subspec 'Base' do |sub|
    sub.source_files = s.name + '/Commons/Classes/**/*'
    sub.public_header_files = s.name + '/Commons/Classes/**/*.h'
    
    sub.frameworks = ['UIKit','Foundation','CoreFoundation','QuartzCore','SystemConfiguration','MobileCoreServices','CoreServices','CoreTelephony','Security']
    sub.weak_frameworks = [ 'AdSupport' ]
  end
  
  s.subspec 'OnlineParameter' do |sub|
    sub.source_files = s.name + '/OnlineParameter/Classes/**/*'
    sub.public_header_files = s.name + '/OnlineParameter/Classes/**/*.h'
    
    sub.frameworks = [ 'CoreTelephony', 'CoreLocation', 'MobileCoreServices', 'SystemConfiguration', 'Security' ]
    sub.weak_frameworks = [ 'AdSupport', 'SafariServices' ]
    
    sub.dependency 'Yodo1Suit/Base',"#{s.version}"
  end
  
  s.subspec 'Analytics' do |sub|
    sub.frameworks = [ 'Foundation', 'UIKit', 'SystemConfiguration', 'CoreGraphics', 'Security', 'CoreTelephony' ]
    sub.weak_frameworks = []
    sub.dependency 'Yodo1Suit/Base',"#{s.version}"
    
    sub.subspec 'Core' do |sub1|
      sub1.source_files = s.name + '/Analytics/Classes/Core/**/*'
      sub1.public_header_files = s.name + '/Analytics/Classes/Core/**/*.h'
      
      sub1.dependency 'ThinkingSDK','2.8.3.2'
    end
    
    sub.subspec 'AppsFlyer' do |sub1|
      sub1.source_files = s.name + '/Analytics/Classes/AppsFlyer/**/*'
      sub1.public_header_files = s.name + '/Analytics/Classes/AppsFlyer/**/*.h'
      sub1.frameworks = ['SystemConfiguration','Security','CoreTelephony','iAd','AdSupport','AdServices','AppTrackingTransparency']
      
      sub1.dependency 'AppsFlyerFramework', '6.7.0'
      sub1.dependency 'Yodo1Suit/Analytics/Core', "#{s.version}"
    end
    
    sub.subspec 'Adjust' do |sub1|
      sub1.source_files = s.name + '/Analytics/Classes/Adjust/**/*'
      sub1.public_header_files = s.name + '/Analytics/Classes/Adjust/**/*.h'
      sub1.frameworks = ['AdSupport','AdServices','StoreKit','AppTrackingTransparency']
      sub1.dependency 'Adjust', '4.33.4'
      sub1.dependency 'Yodo1Suit/Analytics/Core', "#{s.version}"
    end
  end
  
  s.subspec 'UCenter' do |sub|
    sub.source_files = s.name + '/UCenter/Classes/**/*'
    sub.public_header_files = s.name + '/UCenter/Classes/**/*.h'
    
    sub.frameworks = [ 'Foundation', 'UIKit', 'CoreTelephony', 'Security' ]
    sub.weak_frameworks = [ 'AdSupport', 'SafariServices' ]
    
    sub.dependency 'Yodo1Suit/Base',"#{s.version}"
    sub.dependency 'Yodo1Suit/Analytics/Core',"#{s.version}"
  end
  
  s.subspec 'GameCenter' do |sub|
    sub.xcconfig = {
      "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_GAMECENTER',
    }
    
    sub.source_files = s.name + '/GameCenter/Classes/**/*'
    sub.public_header_files = s.name + '/GameCenter/Classes/**/*.h'
    
    sub.frameworks = [ 'Foundation', 'UIKit', 'CoreTelephony', 'MobileCoreServices', 'SystemConfiguration', 'Security']
    sub.weak_frameworks = [ 'AdSupport', 'SafariServices', 'GameKit' ]
    
    sub.dependency 'Yodo1Suit/Base',"#{s.version}"
    sub.dependency 'Yodo1Suit/Analytics/Core',"#{s.version}"
    sub.dependency 'Yodo1Suit/UCenter',"#{s.version}"
  end
  
  s.subspec 'iCloud' do |sub|
    sub.xcconfig = {
      "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ICLOUD',
    }
    
    sub.source_files = s.name + '/iCloud/Classes/**/*'
    sub.public_header_files = s.name + '/iCloud/Classes/**/*.h'
    
    sub.frameworks = [ 'Foundation', 'UIKit', 'CoreTelephony', 'MobileCoreServices', 'SystemConfiguration', 'Security']
    sub.weak_frameworks = [ 'AdSupport', 'SafariServices', 'CloudKit' ]
    
    sub.dependency 'Yodo1Suit/Base',"#{s.version}"
  end
  
  s.subspec 'iRate' do |sub|
    sub.xcconfig = {
      "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_IRATE',
    }
    
    sub.source_files = s.name + '/iRate/Classes/**/*'
    sub.public_header_files = s.name + '/iRate/Classes/**/*.h'
    sub.resource = s.name + '/iRate/Assets/**/*.bundle'
    sub.frameworks = [ 'StoreKit' ]
  end
  
  s.subspec 'Notification' do |sub|
    sub.xcconfig = {
      "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_NOTIFICATION',
    }
    
    sub.source_files = s.name + '/Notification/Classes/**/*'
    sub.public_header_files = s.name + '/Notification/Classes/**/*.h'
    
    sub.dependency 'Yodo1Suit/Base',"#{s.version}"
  end
  
  s.subspec 'Replay' do |sub|
    sub.xcconfig = {
      "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_REPLAY',
    }
    
    sub.source_files = s.name + '/Replay/Classes/**/*'
    sub.public_header_files = s.name + '/Replay/Classes/**/*.h'
    sub.weak_frameworks = [ 'ReplayKit' ]
    
    sub.dependency 'Yodo1Suit/Base',"#{s.version}"
  end
  
  s.subspec 'Purchase' do |sub|
    sub.xcconfig = {
      "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_UCCENTER',
    }
    
    sub.source_files = s.name + '/Purchase/Classes/**/*'
    sub.public_header_files = s.name + '/Purchase/Classes/**/*.h'
    sub.resource = s.name + '/Purchase/Assets/**/*.bundle'
    sub.frameworks = [ 'Foundation', 'UIKit', 'CoreTelephony',  'CoreLocation', 'ImageIO', 'MobileCoreServices', 'StoreKit', 'WebKit', 'SystemConfiguration',  'Security']
    sub.weak_frameworks = [ 'AdSupport', 'SafariServices' ]
    
    sub.dependency 'Yodo1Suit/Base',"#{s.version}"
    sub.dependency 'Yodo1Suit/Analytics/Core',"#{s.version}"
    sub.dependency 'Yodo1Suit/UCenter',"#{s.version}"
  end
  
  s.subspec 'Core' do |sub|
    sub.source_files = s.name + '/Core/Classes/**/*'
    sub.public_header_files = s.name + '/Core/Classes/**/*.h'
    sub.resource = s.name + '/Core/Assets/**/*.bundle'
    
    sub.frameworks = [ 'Foundation', 'UIKit', 'Security']
    sub.weak_frameworks = ['AdSupport','SafariServices']
    
    sub.dependency 'Yodo1Suit/OnlineParameter',"#{s.version}"
    sub.dependency 'Yodo1Suit/Analytics/Core',"#{s.version}"
    sub.dependency 'Yodo1Suit/UCenter',"#{s.version}"
  end
  
  s.subspec 'UnityCore' do |sub|
    sub.dependency 'Yodo1Suit/Core',"#{s.version}"
    
    sub.dependency 'Yodo1Suit/GameCenter',"#{s.version}"
    sub.dependency 'Yodo1Suit/iRate',"#{s.version}"
    sub.dependency 'Yodo1Suit/Replay',"#{s.version}"
    sub.dependency 'Yodo1Suit/Notification',"#{s.version}"
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
  #    ss.dependency 'Yodo1Suit/Core',"#{s.version}"
  #end
  
end
