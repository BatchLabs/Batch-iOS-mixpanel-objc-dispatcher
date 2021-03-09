Pod::Spec.new do |s|
  s.name             = 'BatchMixpanelObjcDispatcher'
  s.version          = '2.0.0'
  s.summary          = 'Batch.com Events Dispatcher Mixpanel implementation.'

  s.description      = <<-DESC
  A ready-to-go event dispatcher for the Mixpanel Objective-C SDK. Requires the Batch iOS SDK.
                       DESC

  s.homepage         = 'https://batch.com'
  s.license          = { :type => 'MIT' }
  s.author           = { 'Batch.com' => 'support@batch.com' }
  s.source           = { :git => 'https://github.com/BatchLabs/Batch-iOS-mixpanel-objc-dispatcher.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'
  s.platforms = {
    "ios" => "10.0"
  }

  s.requires_arc = true
  s.static_framework = true
  
  s.dependency 'Batch', '~> 1.17'
  s.dependency 'Mixpanel'
  
  s.source_files = 'BatchMixpanelObjcDispatcher/Classes/**/*'
end
