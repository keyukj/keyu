Pod::Spec.new do |s|
  s.name             = 'TanyuApp'
  s.version          = '1.0.4'
  s.summary          = 'TanyuApp Flutter Framework for iOS'
  s.description      = <<-DESC
    TanyuApp is a Flutter-based framework that can be integrated into native iOS applications.
    It provides social networking features including chat, posts, and user profiles.
  DESC

  s.homepage         = 'https://github.com/yourusername/tanyu_app'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Your Name' => 'your.email@example.com' }
  s.source           = { :git => 'https://github.com/yourusername/tanyu_app.git', :tag => s.version.to_s }

  s.ios.deployment_target = '12.0'
  s.swift_version = '5.0'

  # Framework 路径
  s.vendored_frameworks = [
    'build/frameworks/Release/App.xcframework',
    'build/frameworks/Release/Flutter.xcframework',
    'build/frameworks/Release/FlutterPluginRegistrant.xcframework',
    'build/frameworks/Release/in_app_purchase_storekit.xcframework',
    'build/frameworks/Release/shared_preferences_foundation.xcframework',
    'build/frameworks/Release/url_launcher_ios.xcframework',
    'build/frameworks/Release/webview_flutter_wkwebview.xcframework'
  ]

  # 资源文件
  s.resources = 'build/frameworks/Release/App.xcframework/ios-arm64/App.framework/flutter_assets/**/*'

  # 依赖配置
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
    'OTHER_LDFLAGS' => '-ObjC'
  }

  # 框架依赖
  s.frameworks = 'UIKit', 'Foundation', 'CoreGraphics', 'WebKit', 'StoreKit'

  # 隐私清单
  s.resource_bundles = {
    'TanyuApp_Privacy' => ['ios/Runner/PrivacyInfo.xcprivacy']
  }

end
