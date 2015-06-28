Pod::Spec.new do |s|  
  s.name             = "LCNetwork"  
  s.version          = "0.0.5"
  s.summary          = "基于AFNetworking的网络库封装"
  s.homepage         = "https://github.com/bawn/LCNetwork" 
  s.license          = 'MIT'  
  s.author           = { "bawn" => "lc5491137@gmail.com" }  
  s.source           = { :git => "https://github.com/bawn/LCNetwork.git", :tag => s.version.to_s }   
  s.platform         = :ios, '6.0'
  s.requires_arc     = true  
  s.source_files     = 'LCNetwork/*.{h,m}'
  s.dependency       "AFNetworking", "~> 2.5.4"
  s.dependency       "TMCache", "~> 2.1.0"
  s.dependency       "DateTools", "~> 1.6.0"
end  