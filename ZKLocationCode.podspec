Pod::Spec.new do |s|
  s.name         = "ZKLocationCode"
  s.version      = "0.0.1"
  s.summary      = "A fast integration images loop function of custom control"
  s.description  = "A fast integration images loop function of custom control addtion with cocoapod support."
  s.homepage     = "https://github.com/zhenkunew123/ZKLocationCode"
  s.social_media_url   = "http://www.weibo.com/u/5527441819"
  s.license= { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Adam" => "614451892@11.com" }
  s.source       = { :git => "https://github.com/zhenkunew123/ZKLocationCode.git", :tag => '0.0.1' }
  s.source_files = "ZKLocationCode/*.{h,m}"
  s.ios.deployment_target = '8.0'
  s.frameworks   = 'UIKit', 'Foundation'
  s.requires_arc = true

end