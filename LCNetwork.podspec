Pod::Spec.new do |s|
  s.name             = "LCNetwork"
  s.version          = "1.1.7"
  s.summary          = "基于AFNetworking的网络库封装"
  s.homepage         = "https://github.com/bawn/LCNetwork"
  s.license          = 'MIT'
  s.author           = { "bawn" => "lc5491137@gmail.com" }
  s.source           = { :git => "https://github.com/bawn/LCNetwork.git", :tag => s.version.to_s }
  s.platform         = :ios, '7.0'
  s.requires_arc     = true
  s.source_files     = 'LCNetwork/*.{h,m}'
  s.dependency       "AFNetworking"
  s.dependency       "TMCache", "~> 2.1.0"
end
