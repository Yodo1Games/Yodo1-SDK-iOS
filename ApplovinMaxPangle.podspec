Pod::Spec.new do |s|
    s.name             = 'ApplovinMaxPangle'
    s.version          = '6.1.0'
    s.summary          = 'v 6.0.8.1 是优汇量版本'

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

    # s.source_files = [ "*.h" ]

    # s.public_header_files = [ "*.h" ]

    # s.vendored_libraries = [ "*.a" ]
    
    s.vendored_frameworks = ["*.framework"]

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
        'Security',
        'CoreBluetooth']

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
    
    s.dependency 'Ads-CN/Domestic','4.2.5.3'
    s.dependency 'Ads-CN/International','4.2.5.3'
    s.dependency 'Ads-CN','4.2.5.3'
    #s.dependency 'Ads-CN/Domestic','4.1.0.2'
    #s.dependency 'Ads-CN/International','4.1.0.2'
    #s.dependency 'Ads-CN','4.1.0.2'
    s.dependency 'YD1ApplovinMax', '6.0.9'
end
