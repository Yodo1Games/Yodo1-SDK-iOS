Pod::Spec.new do |s|
    s.name             = 'Yodo1Analytics'
    s.version          = '1.0.0'
    s.summary          = 'Core Analytics'

    s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC
    
    s.homepage         = 'https://github.com'
    # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
    s.author           = { 'yixian huang' => 'huangyixian@yodo1.com' }
    s.source           = { :git => 'https://github.com/Yodo1Games/Yodo1-SDK-iOS.git', :tag => "#{s.name}#{s.version}" }
    # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

    s.ios.deployment_target = '9.0'

   
   s.source_files = s.name + '/Classes/**/*'
   s.public_header_files = s.name + '/Classes/**/*.h'

    # s.vendored_libraries = "#{s.version}" + '/*.a'

    s.requires_arc = true

    s.xcconfig = {
        'OTHER_LDFLAGS' => '-ObjC',
        "VALID_ARCHS": "armv7 arm64",
        "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
        "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
    }

    s.frameworks = [
        'SystemConfiguration',
        'Security',
    ]

    s.weak_frameworks = []
    
    s.libraries = [
        'sqlite3.0',
        'z']

    s.dependency 'Yodo1Commons','6.1.1'
    s.dependency 'ThinkingSDK','2.8.1.1'

end
