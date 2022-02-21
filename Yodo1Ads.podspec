Pod::Spec.new do |s|
    s.name             = 'Yodo1Ads'
    s.version          = '6.1.4'
    # s.version          = '0.0.29'
    # s.version          = '6.0.5.1'
    s.summary          = '    
                            添加优汇量统计测试
                            最低支持iOS 10.0
                            广告:v3.16.0
                            大更改
                            修复IS里面的Unity广告bug
                            6.0.3.1是优汇量统计版本，6.0.3是正式版
                            ----------------------------------
                            更新QQ Sdk 分享
                            ---------------
                            6.0.4.1 是优汇量测试版本
                            6.0.5.1 是优汇量测试版本
                            ----------------------
                            更新GDT .a ，Soomla v6.8.4
                        '

    s.description      = <<-DESC
    TODO: Add long description of the pod here.
                       DESC

    s.homepage         = 'https://github.com'
    s.license          = { :type => 'MIT', :file => "LICENSE" }
    s.author           = { 'yixian huang' => 'huangyixian@yodo1.com' }
    s.source           = { :git => 'https://github.com/Yodo1Games/Yodo1-SDK-iOS.git', :tag => "#{s.name}#{s.version}" }
    s.ios.deployment_target = '10.0'

    s.subspec 'Yodo1_Ads' do |ss|
        ss.source_files = [ "*.{h,mm,m}" ]
        
        ss.public_header_files = [ "*.h" ]

        ss.vendored_libraries = [ "*.a" ]

        ss.resources = [ "Yodo1Ads.bundle" ]

        # ss.vendored_frameworks = ["*.framework"]
        
        ss.requires_arc = true
        
        ss.xcconfig = {
            'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }

        ss.frameworks = [
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
        'AppTrackingTransparency']

        ss.weak_frameworks = [
        'AdSupport',
        'SafariServices',
        'ReplayKit',
        'CloudKit',
        'GameKit']

        ss.libraries = [
        'sqlite3.0',
        'c++',
        'z']

        ss.dependency 'Yodo1AdvertSDK','6.0.3'
        ss.dependency 'Bugly','2.5.91'
        ss.dependency 'Yodo1Analytics','6.0.1'
        
    end

    s.subspec 'Yodo1_ConfigKey' do |ss|
        ss.resources = [ "Yodo1KeyConfig.bundle" ]
        ss.xcconfig = {
            'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    end

    s.subspec 'Yodo1_UnityConfigKey' do |ss|
        ss.xcconfig = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'UNITY_PROJECT',
            'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    end

    s.subspec 'Yodo1_Analytics' do |ss|
        ss.xcconfig = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ANALYTICS',
             'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        ss.dependency 'Yodo1Analytics','6.0.1'
        ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    end

    s.subspec 'Yodo1_UCenter' do |ss|
        ss.xcconfig = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_UCCENTER',
            'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        ss.dependency 'Yodo1UCenter','6.0.3'
        ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    end

    s.subspec 'Yodo1_Share' do |ss|
        ss.xcconfig = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_SNS',
            'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        ss.dependency 'Yodo1Share','6.0.2'
        ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    end

    s.subspec 'Yodo1_iRate' do |ss|
        ss.xcconfig = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'IRATE',
            'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        ss.dependency 'Yodo1iRate','6.0.0'
        ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    end

     s.subspec 'Yodo1_GameCenter' do |ss|
        ss.xcconfig = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'GAMECENTER',
                         'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        ss.dependency 'Yodo1GameCenter','6.0.1'
        ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    end
     s.subspec 'Yodo1_iCloud' do |ss|
        ss.xcconfig = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'ICLOUD',
                         'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        ss.dependency 'Yodo1iCloud','6.0.1'
        ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    end
    s.subspec 'Yodo1_Notification' do |ss|
        ss.xcconfig = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'NOTIFICATION',
                         'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        ss.dependency 'Yodo1Notification','6.0.1'
        ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    end

    s.subspec 'Yodo1_Replay' do |ss|
        ss.xcconfig = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'REPLAY',
                         'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        ss.dependency 'Yodo1Replay','6.0.1'
        ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    end

    s.subspec 'Yodo1_Privacy' do |ss|
        ss.xcconfig = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'PRIVACY',
             'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        ss.dependency 'Yodo1Privacy','6.0.1'
        ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    end

#  ################# 统计 ##################
    s.subspec 'Analytics_AppsFlyer' do |ss|
        ss.xcconfig = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ANALYTICS',
                         'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        ss.dependency 'AnalyticsAppsFlyer','6.0.6'
        ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    end

    s.subspec 'Analytics_TalkingData' do |ss|
        ss.xcconfig = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ANALYTICS',
            'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        ss.dependency 'AnalyticsTalkingData','6.0.4'
        ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    end
    
    s.subspec 'Analytics_Umeng' do |ss|
        ss.xcconfig = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ANALYTICS',
            'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        ss.dependency 'AnalyticsUmeng','6.0.4'
        ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    end

    s.subspec 'Analytics_Swrve' do |ss|
        ss.xcconfig = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ANALYTICS',
            'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        ss.dependency 'AnalyticsSwrve','6.0.5'
        ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    end

    s.subspec 'Analytics_Firebase' do |ss|
        ss.xcconfig = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ANALYTICS',
            'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        ss.dependency 'AnalyticsFirebase','6.0.5'
        ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    end

    s.subspec 'Yodo1_Soomla' do |ss|
        ss.xcconfig = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_SOOMLA',
            'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        ss.dependency 'IronSourceAdQualitySDK','6.8.4'
        ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    end

    # s.subspec 'Analytics_Thinking' do |ss|
    #     ss.xcconfig = {
    #         "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ANALYTICS',
    #         'OTHER_LDFLAGS' => '-ObjC',
    #         'ENABLE_BITCODE' => "NO",
    #         "VALID_ARCHS": "armv7 arm64",
    #         "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
    #         "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
    #     }
    #     ss.dependency 'AnalyticsThinking','6.0.0'
    #     ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    # end

 ################# YD1 广告 ##############
    s.subspec 'YD1_Admob' do |ss|
        ss.xcconfig = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ADS',
            'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        ss.dependency 'YD1Admob','6.0.6'
        ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    end

    s.subspec 'YD1_Applovin' do |ss|
        ss.xcconfig = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ADS',
            'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        ss.dependency 'YD1Applovin','6.0.6'
        ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    end

    s.subspec 'YD1_IronSource' do |ss|
        ss.xcconfig = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ADS',
            'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        ss.dependency 'YD1IronSource','6.0.9'
        ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    end

    s.subspec 'YD1_Inmobi' do |ss|
        ss.xcconfig = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ADS',
            'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        ss.dependency 'YD1Inmobi','6.0.7'
        ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    end

    # s.subspec 'YD1_Mintegral' do |ss|
    #     ss.xcconfig = {
    #         "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ADS',
    #         'OTHER_LDFLAGS' => '-ObjC',
    #         'ENABLE_BITCODE' => "NO",
    #         "VALID_ARCHS": "armv7 arm64",
    #         "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
    #         "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
    #     }
    #     ss.dependency 'YD1Mintegral','5.0.5'
    #     ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    # end

    s.subspec 'YD1_Tapjoy' do |ss|
        ss.xcconfig = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ADS',
            'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        ss.dependency 'YD1Tapjoy','6.0.3'
        ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    end

    s.subspec 'YD1_UnityAds' do |ss|
        ss.xcconfig = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ADS',
            'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        ss.dependency 'YD1UnityAds','6.0.5'
        ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    end

    s.subspec 'YD1_Vungle' do |ss|
        ss.xcconfig = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ADS',
            'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        ss.dependency 'YD1Vungle','6.0.9'
        ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    end

    s.subspec 'YD1_Pangle' do |ss|
        ss.xcconfig = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ADS',
            'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        ss.dependency 'YD1Pangle','6.0.8'
        ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    end

    s.subspec 'YD1_Baidu' do |ss|
        ss.xcconfig = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ADS',
            'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        ss.dependency 'YD1Baidu','6.0.6'
        ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    end

    s.subspec 'YD1_Facebook' do |ss|
        ss.xcconfig = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ADS',
            'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        ss.dependency 'YD1Facebook','6.0.5'
        ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    end

    s.subspec 'YD1_GDT' do |ss|
        ss.xcconfig = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ADS',
            'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        # ss.dependency 'YD1GDT','6.0.6.1'
        ss.dependency 'YD1GDT','6.1.1'
        ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    end
    
    s.subspec 'YD1_ApplovinMax' do |ss|
        ss.xcconfig = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ADS',
            'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        ss.dependency 'YD1ApplovinMax','6.0.6'
        ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    end

    s.subspec 'YD1_Chartboost' do |ss|
        ss.xcconfig = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ADS',
            'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        ss.dependency 'YD1Chartboost','6.0.5'
        ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    end

    s.subspec 'YD1_AdColony' do |ss|
        ss.xcconfig = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ADS',
            'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        ss.dependency 'YD1AdColony','6.0.4'
        ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    end

    s.subspec 'YD1_MyTarget' do |ss|
        ss.xcconfig = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ADS',
            'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        ss.dependency 'YD1MyTarget','6.0.8'
        ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    end

    s.subspec 'YD1_Yandex' do |ss|
        ss.xcconfig = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ADS',
            'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        ss.dependency 'YD1Yandex','6.0.6'
        ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    end
    
    # s.subspec 'YD1_Smaato' do |ss|
    #     ss.xcconfig = {
    #         "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ADS',
    #         'OTHER_LDFLAGS' => '-ObjC',
    #         'ENABLE_BITCODE' => "NO",
    #         "VALID_ARCHS": "armv7 arm64",
    #         "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
    #         "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
    #     }
    #     ss.dependency 'YD1Smaato','5.0.2'
    #     ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    # end
    
    # s.subspec 'YD1_Topon' do |ss|
    #     ss.xcconfig = {
    #         "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ADS',
    #         'OTHER_LDFLAGS' => '-ObjC',
    #         'ENABLE_BITCODE' => "NO",
    #         "VALID_ARCHS": "armv7 arm64",
    #         "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
    #         "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
    #     }
    #     ss.dependency 'YD1Topon','5.0.3'
    #     ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    # end

    s.subspec 'YD1_Ohayoo' do |ss|
        ss.xcconfig = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ADS',
            'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        ss.dependency 'YD1Ohayoo','6.0.3'
        ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    end
    ######## YD1 Admob ########
    s.subspec 'Admob_Facebook' do |ss|
        ss.xcconfig = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ADS',
            'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        ss.dependency 'AdmobFacebook','6.0.7'
        ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    end
    s.subspec 'Admob_IronSource' do |ss|
        ss.xcconfig = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ADS',
            'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        ss.dependency 'AdmobIronSource','6.0.9'
        ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    end
    s.subspec 'Admob_Tapjoy' do |ss|
        ss.xcconfig = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ADS',
            'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        ss.dependency 'AdmobTapjoy','6.0.6'
        ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    end
    s.subspec 'Admob_Vungle' do |ss|
        ss.xcconfig = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ADS',
            'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        ss.dependency 'AdmobVungle','6.1.0'
        ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    end

    s.subspec 'Admob_Inmobi' do |ss|
        ss.xcconfig = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ADS',
            'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        ss.dependency 'AdmobInmobi','6.0.7'
        ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    end

    s.subspec 'Admob_UnityAds' do |ss|
        ss.xcconfig = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ADS',
            'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        ss.dependency 'AdmobUnityAds','6.0.7'
        ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    end

    s.subspec 'Admob_Chartboost' do |ss|
        ss.xcconfig = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ADS',
            'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        ss.dependency 'AdmobChartboost','6.0.8'
        ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    end

    s.subspec 'Admob_AppLovin' do |ss|
        ss.xcconfig = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ADS',
            'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        ss.dependency 'AdmobAppLovin','6.0.6'
        ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    end

   s.subspec 'Admob_AdColony' do |ss|
        ss.xcconfig = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ADS',
            'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        ss.dependency 'AdmobAdColony','6.0.7'
        ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    end

    s.subspec 'Admob_MyTarget' do |ss|
        ss.xcconfig = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ADS',
            'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        ss.dependency 'AdmobMyTarget','6.0.9'
        ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    end

    ######## YD1 ApplovinMax ########

    s.subspec 'ApplovinMax_Facebook' do |ss|
        ss.xcconfig = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ADS',
            'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        ss.dependency 'ApplovinMaxFacebook','6.0.8'
        ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    end

    s.subspec 'ApplovinMax_Admob' do |ss|
        ss.xcconfig = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ADS',
            'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        ss.dependency 'ApplovinMaxAdmob','6.0.8'
        ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    end

    s.subspec 'ApplovinMax_Inmobi' do |ss|
        ss.xcconfig = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ADS',
            'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        ss.dependency 'ApplovinMaxInmobi','6.0.8'
        ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    end

    s.subspec 'ApplovinMax_IronSource' do |ss|
        ss.xcconfig = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ADS',
            'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        ss.dependency 'ApplovinMaxIronSource','6.0.9'
        ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    end

    # s.subspec 'ApplovinMax_Mintegral' do |ss|
    #     ss.xcconfig = {
    #         "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ADS',
    #         'OTHER_LDFLAGS' => '-ObjC',
    #         'ENABLE_BITCODE' => "NO",
    #         "VALID_ARCHS": "armv7 arm64",
    #         "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
    #         "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
    #     }
    #     ss.dependency 'ApplovinMaxMintegral','5.0.3'
    #     ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    # end

    s.subspec 'ApplovinMax_Tapjoy' do |ss|
        ss.xcconfig = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ADS',
            'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        ss.dependency 'ApplovinMaxTapjoy','6.0.6'
        ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    end
    s.subspec 'ApplovinMax_UnityAds' do |ss|
        ss.xcconfig = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ADS',
            'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        ss.dependency 'ApplovinMaxUnityAds','6.0.7'
        ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    end
    s.subspec 'ApplovinMax_Vungle' do |ss|
        ss.xcconfig = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ADS',
            'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        ss.dependency 'ApplovinMaxVungle','6.0.9'
        ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    end

    s.subspec 'ApplovinMax_Pangle' do |ss|
        ss.xcconfig = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ADS',
            'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        ss.dependency 'ApplovinMaxPangle','6.0.8'
        ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    end

    s.subspec 'ApplovinMax_Chartboost' do |ss|
        ss.xcconfig = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ADS',
            'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        ss.dependency 'ApplovinMaxChartboost','6.0.8'
        ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    end

    s.subspec 'ApplovinMax_AdColony' do |ss|
        ss.xcconfig = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ADS',
            'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        ss.dependency 'ApplovinMaxAdColony','6.0.6'
        ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    end

    s.subspec 'ApplovinMax_MyTarget' do |ss|
        ss.xcconfig = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ADS',
            'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        ss.dependency 'ApplovinMaxMyTarget','6.0.7'
        ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    end
    
    s.subspec 'ApplovinMax_Yandex' do |ss|
        ss.xcconfig = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ADS',
            'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        ss.dependency 'ApplovinMaxYandex','6.0.7'
        ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    end
    # s.subspec 'ApplovinMax_Smaato' do |ss|
    #     ss.xcconfig = {
    #         "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ADS',
    #         'OTHER_LDFLAGS' => '-ObjC',
    #         'ENABLE_BITCODE' => "NO",
    #         "VALID_ARCHS": "armv7 arm64",
    #         "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
    #         "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
    #     }
    #     ss.dependency 'ApplovinMaxSmaato','5.0.6'
    #     ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    # end

    s.subspec 'ApplovinMax_GDT' do |ss|
        ss.xcconfig = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ADS',
            'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        # ss.dependency 'ApplovinMaxGDT','6.0.5.1'
        ss.dependency 'ApplovinMaxGDT','6.0.9'
        ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    end

    # s.subspec 'ApplovinMax_Amazon' do |ss|
    #     ss.xcconfig = {
    #         "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ADS',
    #         'OTHER_LDFLAGS' => '-ObjC',
    #         'ENABLE_BITCODE' => "NO",
    #         "VALID_ARCHS": "armv7 arm64",
    #         "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
    #         "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
    #     }
    #     ss.dependency 'ApplovinMaxAmazon','5.0.3'
    #     ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    # end

    # s.subspec 'ApplovinMax_Verizon' do |ss|
    #     ss.xcconfig = {
    #         "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ADS',
    #         'OTHER_LDFLAGS' => '-ObjC',
    #         'ENABLE_BITCODE' => "NO",
    #         "VALID_ARCHS": "armv7 arm64",
    #         "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
    #         "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
    #     }
    #     ss.dependency 'ApplovinMaxVerizon','5.0.5'
    #     ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    # end

    s.subspec 'ApplovinMax_Fyber' do |ss|
        ss.xcconfig = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ADS',
            'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        ss.dependency 'ApplovinMaxFyber','6.0.8'
        ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    end
    ######## YD1Topon ########
    # s.subspec 'Topon_Baidu' do |ss|
    #     ss.xcconfig = {
    #         "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ADS',
    #         'OTHER_LDFLAGS' => '-ObjC',
    #         'ENABLE_BITCODE' => "NO",
    #         "VALID_ARCHS": "armv7 arm64",
    #         "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
    #         "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
    #     }
    #     ss.dependency 'ToponBaidu','5.0.4'
    #     ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    # end
    # s.subspec 'Topon_Mintegral' do |ss|
    #     ss.xcconfig = {
    #         "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ADS',
    #         'OTHER_LDFLAGS' => '-ObjC',
    #         'ENABLE_BITCODE' => "NO",
    #         "VALID_ARCHS": "armv7 arm64",
    #         "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
    #         "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
    #     }
    #     ss.dependency 'ToponMintegral','5.0.5'
    #     ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    # end
    # s.subspec 'Topon_Sigmob' do |ss|
    #     ss.xcconfig = {
    #         "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ADS',
    #         'OTHER_LDFLAGS' => '-ObjC',
    #         'ENABLE_BITCODE' => "NO",
    #         "VALID_ARCHS": "armv7 arm64",
    #         "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
    #         "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
    #     }
    #     ss.dependency 'ToponSigmob','5.0.4'
    #     ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    # end

    # s.subspec 'Topon_UnityAds' do |ss|
    #     ss.xcconfig = {
    #         "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ADS',
    #         'OTHER_LDFLAGS' => '-ObjC',
    #         'ENABLE_BITCODE' => "NO",
    #         "VALID_ARCHS": "armv7 arm64",
    #         "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
    #         "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
    #     }
    #     ss.dependency 'ToponUnityAds','5.0.5'
    #     ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    # end

    # s.subspec 'Topon_GDT' do |ss|
    #     ss.xcconfig = {
    #         "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ADS',
    #         'OTHER_LDFLAGS' => '-ObjC',
    #         'ENABLE_BITCODE' => "NO",
    #         "VALID_ARCHS": "armv7 arm64",
    #         "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
    #         "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
    #     }
    #     ss.dependency 'ToponGDT','5.0.4'
    #     ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    # end

    # s.subspec 'Topon_Admob' do |ss|
    #     ss.xcconfig = {
    #         "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ADS',
    #         'OTHER_LDFLAGS' => '-ObjC',
    #         'ENABLE_BITCODE' => "NO",
    #         "VALID_ARCHS": "armv7 arm64",
    #         "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
    #         "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
    #     }
    #     ss.dependency 'ToponAdmob','5.0.4'
    #     ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    # end

    # s.subspec 'Topon_Vungle' do |ss|
    #     ss.xcconfig = {
    #         "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ADS',
    #         'OTHER_LDFLAGS' => '-ObjC',
    #         'ENABLE_BITCODE' => "NO",
    #         "VALID_ARCHS": "armv7 arm64",
    #         "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
    #         "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
    #     }
    #     ss.dependency 'ToponVungle','5.0.3'
    #     ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    # end

    # s.subspec 'Topon_Pangle' do |ss|
    #     ss.xcconfig = {
    #         "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ADS',
    #         'OTHER_LDFLAGS' => '-ObjC',
    #         'ENABLE_BITCODE' => "NO",
    #         "VALID_ARCHS": "armv7 arm64",
    #         "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
    #         "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
    #     }
    #     ss.dependency 'ToponPangle','5.0.5'
    #     ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    # end

    ######## YD1ISource ########

    #已经启用IronSource聚合
    s.subspec 'IS_Facebook' do |ss|
        ss.xcconfig = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ADS',
            'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        ss.dependency 'ISFacebook','6.0.9'
        ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    end
    
    s.subspec 'IS_Admob' do |ss|
        ss.xcconfig = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ADS',
            'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        ss.dependency 'ISAdmob','6.0.9'
        ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    end
    
    s.subspec 'IS_Vungle' do |ss|
        ss.xcconfig = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ADS',
            'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        ss.dependency 'ISVungle','6.1.0'
        ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    end
    
    s.subspec 'IS_UnityAds' do |ss|
         ss.xcconfig = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ADS',
            'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        ss.dependency 'ISUnityAds','6.0.9'
        ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    end

    s.subspec 'IS_Tapjoy' do |ss|
        ss.xcconfig = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ADS',
            'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        ss.dependency 'ISTapjoy','6.0.8'
        ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    end
    
    s.subspec 'IS_AppLovin' do |ss|
         ss.xcconfig = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ADS',
            'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        ss.dependency 'ISAppLovin','6.0.9'
        ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    end
    
    s.subspec 'IS_Inmobi' do |ss|
         ss.xcconfig = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ADS',
            'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        ss.dependency 'ISInmobi','6.1.0'
        ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    end

    s.subspec 'IS_Pangle' do |ss|
         ss.xcconfig = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ADS',
            'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        ss.dependency 'ISPangle','6.1.0'
        ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    end

    s.subspec 'IS_Chartboost' do |ss|
         ss.xcconfig = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ADS',
            'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        ss.dependency 'ISChartboost','6.0.9'
        ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    end

    s.subspec 'IS_AdColony' do |ss|
         ss.xcconfig = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ADS',
            'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        ss.dependency 'ISAdColony','6.0.8'
        ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    end

    s.subspec 'IS_MyTarget' do |ss|
         ss.xcconfig = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ADS',
            'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        ss.dependency 'ISMyTarget','6.1.0'
        ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    end

    s.subspec 'IS_Fyber' do |ss|
         ss.xcconfig = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'YODO1_ADS',
            'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        ss.dependency 'ISFyber','6.1.0'
        ss.dependency 'Yodo1Ads/Yodo1_Ads',"#{s.version}"
    end

end
