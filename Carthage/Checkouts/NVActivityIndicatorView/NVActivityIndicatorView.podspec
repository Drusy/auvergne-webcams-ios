Pod::Spec.new do |s|
  s.name         = "NVActivityIndicatorView"
  s.version      = "3.5.2"
  s.summary      = "A collection of awesome loading animations"
  s.homepage     = "https://github.com/ninjaprox/NVActivityIndicatorView"
  s.screenshot  = "https://raw.githubusercontent.com/ninjaprox/NVActivityIndicatorView/master/Demo.gif"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Vinh Nguyen" => "ninjaprox@gmail.com" }
  s.social_media_url   = "http://twitter.com/ninjaprox"

  s.ios.deployment_target = "8.0"
  s.tvos.deployment_target = "9.0"

  s.source       = { :git => "https://github.com/ninjaprox/NVActivityIndicatorView.git", :tag => s.version }
  s.source_files  = "NVActivityIndicatorView/**/*.swift"

  s.frameworks = "UIKit", "QuartzCore"
end
