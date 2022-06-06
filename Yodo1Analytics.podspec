Pod::Spec.new do |s|
    s.name             = 'Yodo1Analytics'
    s.version          = '6.1.2'
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

   
    s.source_files = [
        "*.{h,m,mm}",
        "AnalyticsAdapterThinking/*.{h,m}",
        "AnalyticsAdapterAppsFlyer/*.{h,m}"]

    s.public_header_files = [
        "*.h",
        "AnalyticsAdapterThinking/*.h",
        "AnalyticsAdapterAppsFlyer/*.h"]

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
        'StoreKit',
        'WebKit',
        'SystemConfiguration',
        'AudioToolbox',
        'Security',
        'CoreBluetooth'
    ]

    s.weak_frameworks = [
        'AdSupport',
        'SafariServices',
        'ReplayKit',
        'CloudKit',
        'GameKit'
    ]
    
    s.libraries = [
        'sqlite3.0',
        'c++',
        'z']

    s.dependency 'Yodo1Commons','6.1.0'
    s.dependency 'AppsFlyerFramework', '6.5.4'
    s.dependency 'ThinkingSDK','2.7.5'

end
