Pod::Spec.new do |s|

    s.name                = 'AppstudMapLauncher'
    s.version             = '2.0.2'
    s.summary             = 'AppstudMapLauncher is a library for iOS written in Swift that helps navigation with various mapping applications'
    s.homepage            = 'https://github.com/appstud/AppstudMapLauncher'
    s.license             = {
        :type => 'MIT',
        :file => 'LICENSE'
    }
    s.author              = {
        'Appstud' => 'developers@appstud.com'
    }
    s.source              = {
        :git => 'https://github.com/appstud/AppstudMapLauncher.git',
        :tag => s.version.to_s
    }
    s.ios.deployment_target = '9.0'
    s.source_files        = 'AppstudMapLauncher/Source/*.swift'
    s.resources           = 'AppstudMapLauncher/*/*.strings'
    s.requires_arc        = true

end
