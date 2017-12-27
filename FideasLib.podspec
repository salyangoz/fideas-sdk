
Pod::Spec.new do |s|
  s.name             = 'FideasLib'
  s.version          = '0.2.2'
  s.summary          = 'Fideas Mobile Application Development SDK'
 
  s.description      = <<-DESC
Bu SDK ile mobil uygulamanin Fideas uzerinden 
                       DESC
 
  s.homepage         = 'https://github.com/salyangoz/fideas-sdk'
  s.license          = { :type => 'MIT', :file => '/Users/serhatyalcin/Documents/IOS Development/Salyangoz/FideasLib/LICENSE.md' }
  s.author           = { 'Salyangoz' => 'info@salyangoz.com.tr' }
  s.source           = { :git => 'https://github.com/salyangoz/fideas-sdk.git', :branch => "master", :tag => s.version.to_s }
  s.dependency 'Alamofire'
  s.dependency 'AlamofireSwiftyJSON'
  s.dependency 'SWXMLHash', '~> 4.0.0'
  s.ios.deployment_target = '9.0'
  s.source_files = 'FideasLib/'
 
end