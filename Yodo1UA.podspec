Pod::Spec.new do |s|
    s.name             = 'Yodo1UA'
    s.version          = '1.0.0'
    s.summary          = 'User Acquisition'

    s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC
    
    s.homepage         = 'https://github.com'
    # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
    #s.license          = { :type => 'MIT', :file => "LICENSE" }
    s.author           = { 'Yodo1Games' => 'devadmin@yodo1.com' }
    s.source           = { :git => 'https://github.com/Yodo1Games/Yodo1-SDK-iOS.git', :tag => "#{s.name}#{s.version}" }
    # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

    s.ios.deployment_target = '10.0'
    # s.vendored_libraries = "#{s.version}" + '/*.a'
    s.requires_arc = true

    s.xcconfig = {
        'OTHER_LDFLAGS' => '-ObjC',
        "VALID_ARCHS": "armv7 arm64",
        "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
        "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
    }
    s.source_files = s.name + '/Classes/**/*'
    s.public_header_files = s.name + '/Classes/**/*.h'
    s.frameworks = ['AdSupport','iAd','AdServices',]
    s.weak_frameworks = []
    s.libraries = []

    s.dependency 'Yodo1Commons','6.1.1'
    s.dependency 'AppsFlyerFramework', '6.7.0'
#    s.dependency 'ThinkingSDK','2.8.1.1'

end
