Pod::Spec.new do |spec|
    spec.name           = 'Common'
    spec.version        = '1.0'
    spec.swift_version  = '5.0'
    spec.author         = 'Mobile Madness'
    spec.homepage       = 'https://github.com/egarc/common'
    spec.source         = { :git => 'https://github.com/egarc/common.git',
                            :branch => 'master' }
    spec.summary        = 'Framework for common files used in all Mobile Madness apps.'

    spec.source_files = 'Common/**/*.swift'
    
    spec.ios.deployment_target = '11.0'
end