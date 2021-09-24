#
#  Be sure to run `pod spec lint YDKit.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  spec.name         = "YDAvoidCrashKit"
  spec.version      = "0.0.5"
  spec.summary      = "防崩溃、性能检测等"

  spec.homepage     = "https://github.com/chong2vv/YDKit"

  spec.license      = "MIT"

  spec.author             = { "王远东" => "chong2vv@gmail.com" }
  # spec.social_media_url   = "https://twitter.com/王远东"

  spec.platform     = :ios, "9.0"

  spec.source       = { :git => "https://github.com/chong2vv/YDAvoidCrashKit.git", :tag => "#{spec.version}" }

  spec.source_files = "YDAvoidCrashKit/**/*.{h,m}","YDAvoidCrashKit/*.{h,m}"
  spec.public_header_files = "YDAvoidCrashKit/*.h","YDAvoidCrashKit/**/*.h", "YDAvoidCrashKit/**/**/*.h"
  
  spec.libraries = 'c++'
#  ss.source_files = 'YDAvoidCrashKit/YDLogger/*', "YDAvoidCrashKit/YDLogger/**/*.{h,m}"
  spec.xcconfig = {
  'GCC_PREPROCESSOR_DEFINITIONS' => 'ARTLOGGERHYLOG=1',
  }
#  spec.subspec 'YDLogger' do |ss|
#      ss.libraries = 'c++'
#      ss.source_files = 'YDAvoidCrashKit/YDLogger/*', "YDAvoidCrashKit/YDLogger/**/*.{h,m}"
#      ss.xcconfig = {
#      'GCC_PREPROCESSOR_DEFINITIONS' => 'ARTLOGGERHYLOG=1',
#    }
#  end
  spec.requires_arc = true
  spec.frameworks = "Foundation", "UIKit"
  spec.dependency "FMDB"



end
