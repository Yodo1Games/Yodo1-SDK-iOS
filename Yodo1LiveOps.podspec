Pod::Spec.new do |s|
    s.name             = 'Yodo1LiveOps'
    s.version          = '1.0.0'
    s.summary          = 'LiveOps 1.0.0'

    s.description      = <<-DESC
    TODO: Add long description of the pod here.
                       DESC
    

    s.homepage         = 'https://github.com'
    s.author           = { 'yixian huang' => 'huangyixian@yodo1.com' }
    #s.license          = { :type => 'MIT', :file => "LICENSE" }
    s.source           = { :git => 'https://github.com/Yodo1Games/Yodo1-SDK-iOS.git', :tag => "#{s.name}#{s.version}" }
    # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

    s.ios.deployment_target = '10.0'
    # s.vendored_libraries = "#{s.version}" + '/*.a'
    s.requires_arc = true

    s.source_files = s.name + '/Classes/**/*'
    s.public_header_files = s.name + '/Classes/**/*.h'

    s.xcconfig = {
        "OTHER_LDFLAGS" => "-ObjC",
        "VALID_ARCHS": "armv7 arm64",
        "VALID_ARCHS[sdk=iphoneos*]": "armv7 arm64",
        "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
    }

    s.frameworks = []
    s.weak_frameworks = []
    s.libraries = []

    s.dependency 'Yodo1Commons', '6.1.1'

end
