Pod::Spec.new do |s|
    s.name             = 'MasSdk'
    s.version          = '3.17.5.1'
    # s.version          = '3.16.8.1'
    s.summary          = '广告聚合发布:修复IS的bug --> 这个版本是优汇量统计版本--3.16.3.1优汇量版本'
    
    # customVersion    = "6.1.1"
    customVersion    = "6.1.4.2"

    s.description      = <<-DESC
    TODO: Add long description of the pod here.
                       DESC

    s.homepage         = 'https://github.com'
    s.license          = { :type => 'MIT', :file => "LICENSE" }
    s.author           = { 'yixian huang' => 'huangyixian@yodo1.com' }
    s.source           = { :git => 'https://github.com/Yodo1Games/Yodo1-SDK-iOS.git', :tag => "#{s.name}#{s.version}" }
    s.ios.deployment_target = '10.0'

    s.subspec 'MasSdk_iOS' do |ss|
        ss.xcconfig = {
            'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }
        ss.dependency 'Yodo1Ads/Yodo1_ConfigKey', "#{customVersion}"
    end

    s.subspec 'MasSdk_Unity' do |ss|
        ss.xcconfig = {
            "GCC_PREPROCESSOR_DEFINITIONS" => 'UNITY_PROJECT',
            'OTHER_LDFLAGS' => '-ObjC',
            'ENABLE_BITCODE' => "NO",
            "VALID_ARCHS": "armv7 arm64",
            "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
            "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
        }

        ss.dependency 'Yodo1Ads/Yodo1_UnityConfigKey', "#{customVersion}"
    end

    # Admob
    s.dependency 'Yodo1Ads/Admob_AdColony', "#{customVersion}"
    s.dependency 'Yodo1Ads/Admob_AppLovin', "#{customVersion}"
    s.dependency 'Yodo1Ads/Admob_Facebook', "#{customVersion}"
    s.dependency 'Yodo1Ads/Admob_Inmobi', "#{customVersion}"
    s.dependency 'Yodo1Ads/Admob_IronSource', "#{customVersion}"
    s.dependency 'Yodo1Ads/Admob_MyTarget', "#{customVersion}"
    s.dependency 'Yodo1Ads/Admob_Tapjoy', "#{customVersion}"
    s.dependency 'Yodo1Ads/Admob_UnityAds', "#{customVersion}"
    s.dependency 'Yodo1Ads/Admob_Vungle', "#{customVersion}"
    # ApplovinMax
    s.dependency 'Yodo1Ads/ApplovinMax_AdColony', "#{customVersion}"
    s.dependency 'Yodo1Ads/ApplovinMax_Admob', "#{customVersion}"
    # s.dependency 'Yodo1Ads/ApplovinMax_Amazon', "#{customVersion}"
    s.dependency 'Yodo1Ads/ApplovinMax_Facebook', "#{customVersion}"
    s.dependency 'Yodo1Ads/ApplovinMax_Fyber', "#{customVersion}"
    s.dependency 'Yodo1Ads/ApplovinMax_GDT', "#{customVersion}"
    s.dependency 'Yodo1Ads/ApplovinMax_Inmobi', "#{customVersion}"
    s.dependency 'Yodo1Ads/ApplovinMax_IronSource', "#{customVersion}"
    # s.dependency 'Yodo1Ads/ApplovinMax_Mintegral', "#{customVersion}"
    s.dependency 'Yodo1Ads/ApplovinMax_MyTarget', "#{customVersion}"
    s.dependency 'Yodo1Ads/ApplovinMax_Pangle', "#{customVersion}"
    # s.dependency 'Yodo1Ads/ApplovinMax_Smaato', "#{customVersion}"
    s.dependency 'Yodo1Ads/ApplovinMax_Tapjoy', "#{customVersion}"
    s.dependency 'Yodo1Ads/ApplovinMax_UnityAds', "#{customVersion}"
    # s.dependency 'Yodo1Ads/ApplovinMax_Verizon', "#{customVersion}"
    s.dependency 'Yodo1Ads/ApplovinMax_Vungle', "#{customVersion}"
    s.dependency 'Yodo1Ads/ApplovinMax_Yandex', "#{customVersion}"
    # Yodo1
    # s.dependency 'Yodo1Ads/YD1_AdColony', "#{customVersion}"
    s.dependency 'Yodo1Ads/YD1_Admob', "#{customVersion}"
    s.dependency 'Yodo1Ads/YD1_Applovin', "#{customVersion}"
    s.dependency 'Yodo1Ads/YD1_ApplovinMax', "#{customVersion}"
    # s.dependency 'Yodo1Ads/YD1_Facebook', "#{customVersion}"
    s.dependency 'Yodo1Ads/YD1_GDT', "#{customVersion}"
    # s.dependency 'Yodo1Ads/YD1_Inmobi', "#{customVersion}"
    s.dependency 'Yodo1Ads/YD1_IronSource', "#{customVersion}"
    # s.dependency 'Yodo1Ads/YD1_Mintegral', "#{customVersion}"
    # s.dependency 'Yodo1Ads/YD1_MyTarget', "#{customVersion}"
    s.dependency 'Yodo1Ads/YD1_Pangle', "#{customVersion}"
    # s.dependency 'Yodo1Ads/YD1_Smaato', "#{customVersion}"
    # s.dependency 'Yodo1Ads/YD1_Tapjoy', "#{customVersion}"
    # s.dependency 'Yodo1Ads/YD1_UnityAds', "#{customVersion}"
    # s.dependency 'Yodo1Ads/YD1_Vungle', "#{customVersion}"
    # s.dependency 'Yodo1Ads/YD1_Yandex', "#{customVersion}"

end
