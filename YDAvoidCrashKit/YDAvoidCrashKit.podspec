#
#  Be sure to run `pod spec lint YDKit.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  spec.name         = "YDAvoidCrashKit"
  spec.version      = "0.0.7"
  spec.summary      = "防崩溃、性能检测等"

  spec.homepage     = "https://github.com/chong2vv/YDAvoidCrashKit"

  spec.license      = "MIT"

  spec.author             = { "王远东" => "chong2vv@gmail.com" }
  # spec.social_media_url   = "https://twitter.com/王远东"

  spec.platform     = :ios, "9.0"

  spec.source       = { :git => "https://github.com/chong2vv/YDAvoidCrashKit.git", :tag => "#{spec.version}" }
  spec.source_files = "YDAvoidCrashKit/**/*.{h,m}","YDAvoidCrashKit/*.{h,m}"
  spec.public_header_files = "YDAvoidCrashKit/*.h","YDAvoidCrashKit/**/*.h", "YDAvoidCrashKit/**/**/*.h"
  
  spec.subspec 'YDLogger' do |log_ss|
      log_ss.libraries = 'c++'
      log_ss.source_files = 'YDAvoidCrashKit/YDLogger/*', "YDAvoidCrashKit/YDLogger/**/*.{h,m}"
  end
  
  spec.subspec 'YDLoggerUI' do |logui_ss|
      logui_ss.source_files = 'YDAvoidCrashKit/YDLoggerUI/*', "YDAvoidCrashKit/YDLoggerUI/**/*.{h,m}"
      logui_ss.dependency 'YDAvoidCrashKit/YDLogger'
  end
  
  spec.subspec 'YDAvoidCrash' do |crash_ss|
      crash_ss.source_files = 'YDAvoidCrashKit/YDAvoidCrash/*', "YDAvoidCrashKit/YDAvoidCrash/**/*.{h,m}"
      crash_ss.dependency 'YDAvoidCrashKit/YDLogger'
      
      crash_ss.subspec 'YDAvoidCrashUtil' do |crash_util_ss|
          crash_util_ss.source_files = "YDAvoidCrashKit/YDAvoidCrash/YDAvoidCrashUtil/*.{h,m}"
      end
      
      crash_ss.subspec 'YDAvoidCrashCategory' do |crash_cate_ss|
          crash_cate_ss.source_files = "YDAvoidCrashKit/YDAvoidCrash/YDAvoidCrashCategory/*.{h,m}"
      end
  end
  
  spec.subspec 'YDMonitor' do |crash_ss|
      crash_ss.source_files = 'YDAvoidCrashKit/YDMonitor/*', "YDAvoidCrashKit/YDMonitor/**/*.{h,m}"
  end
  
  spec.static_framework = true
  spec.requires_arc = true
  spec.frameworks = "Foundation", "UIKit"

end
