Pod::Spec.new do |spec|
  spec.name         = 'NgKeyboardTracker'
  spec.version      = '1.0.6'
  spec.summary      = 'Objective-c library for tracking keyboard in iOS apps.'
  spec.homepage     = 'https://github.com/meiwin/NgKeyboardTracker'
  spec.author       = { 'Meiwin Fu' => 'meiwin@blockthirty.com' }
  spec.source       = { :git => 'https://github.com/meiwin/ngkeyboardtracker.git', :tag => "v#{spec.version}" }
  spec.source_files = 'NgKeyboardTracker/**/*.{h,m}'
  spec.requires_arc = true
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.frameworks   = 'UIKit'
  spec.ios.deployment_target = "8.0"
end