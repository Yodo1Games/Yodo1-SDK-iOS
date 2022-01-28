Pod::Spec.new do |s|
    s.name             = 'OpenSuitThirdsAnalytics'
    s.version          = '1.0.3'
    s.summary          = '重构数据统计'

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

   
    s.source_files = [ "*.{h,m,mm}" ]

    s.public_header_files = [ "*.h" ]

    # s.vendored_libraries = "#{s.version}" + '/*.a'

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
        'CoreMotion' ,
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
        'Security'
    ]

    s.weak_frameworks = [
        'AdSupport',
        'SafariServices',
        'ReplayKit',
        'CloudKit',
        'GameKit'
    ]
    
    s.libraries = ['sqlite3', 'z']

    s.dependency 'Yodo1OnlineParameter','6.0.1'
    s.dependency 'ThinkingSDK','2.7.3'

end
