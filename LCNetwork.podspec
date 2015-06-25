Pod::Spec.new do |s|  
  s.name             = "LCNetwork"  
  s.version          = "0.0.1"
  s.summary          = "LCNetwork is a high level request util based on AFNetworking"
  s.homepage         = "https://github.com/bawn/LCNetwork" 
  s.license          = 'MIT'  
  s.author           = { "bawn" => "lc5491137@gmail.com" }  
  s.source           = { :git => "https://github.com/bawn/LCNetwork.git", :tag => "0.0.1" }   
  s.platform         = :ios, '6.0'
  s.requires_arc     = true  
  s.source_files     = 'LCNetwork/*.{h,m}'
  s.dependency       "AFNetworking", "~> 2.5.4"
  s.dependency       "TMCache", "~> 2.1.0"
end  