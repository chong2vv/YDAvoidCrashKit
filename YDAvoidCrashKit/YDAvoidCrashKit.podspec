#
#  Be sure to run `pod spec lint YDKit.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  spec.name         = "YDAvoidCrashKit"
  spec.version      = "0.1.1"
  spec.summary      = "防崩溃、性能检测等"

  spec.homepage     = "https://github.com/chong2vv/YDAvoidCrashKit"

  spec.license      = "MIT"

  spec.author             = { "王远东" => "chong2vv@gmail.com" }
  # spec.social_media_url   = "https://twitter.com/王远东"

  spec.platform     = :ios, "9.0"

  spec.source       = { :git => "https://github.com/chong2vv/YDAvoidCrashKit.git", :tag => "#{spec.version}" }
  spec.source_files = "YDAvoidCrashKit/*"
#  spec.public_header_files = "YDAvoidCrashKit/*.h","YDAvoidCrashKit/**/*.h", "YDAvoidCrashKit/**/**/*.h"
  
  spec.subspec 'YDLogger' do |log_ss|
      log_ss.libraries = 'c++'
      log_ss.source_files = "YDAvoidCrashKit/YDLogger/**/*"
  end
  
  spec.subspec 'YDLoggerUI' do |logui_ss|
      logui_ss.source_files = "YDAvoidCrashKit/YDLoggerUI/**/*"
      logui_ss.dependency 'YDAvoidCrashKit/YDLogger'
  end
  
  spec.subspec 'YDAvoidCrash' do |crash_ss|
      crash_ss.source_files = "YDAvoidCrashKit/YDAvoidCrash/**/*"
      crash_ss.dependency 'YDAvoidCrashKit/YDLogger'
      crash_ss.dependency 'YDAvoidCrashKit/YDSafeThread'
  end
  
  spec.subspec 'YDMonitor' do |monitor_ss|
      monitor_ss.source_files = "YDAvoidCrashKit/YDMonitor/**/*"
      monitor_ss.dependency 'YDAvoidCrashKit/YDLogger'
  end
  
  spec.subspec 'YDSafeThread' do |safe_thread_ss|
      safe_thread_ss.source_files = "YDAvoidCrashKit/YDSafeThread/**/*"
  end
  
  spec.static_framework = true
  spec.requires_arc = true
  spec.frameworks = "Foundation", "UIKit"

end
