#
#  Be sure to run `pod spec lint GeneralInterface.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  s.name         = "GeneralInterface"
  s.version      = "0.0.1"
  s.summary      = "GeneralInterface"

  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  s.description  = <<-DESC
                  TODO: GeneralInterface TestLibrary!!!
                   DESC

  s.homepage     = "https://github.com/cpllj/GeneralInterface.git"
  s.license      = { :type => "MIT", :file => "./LICENSE" }
  s.author             = { "鲁利杰" => "" }
  s.source       = { :git => "https://github.com/cpllj/GeneralInterface.git", :tag => "#{s.version}" }
  s.source_files  = "GeneralInterface", "interfaceInclude"
  s.frameworks = "UIKit", "CoreText", "XCTest", "CoreTelephony", "Foundation"
  s.vendored_libraries  = "interfaceLibs/Sharelibs/*.a", "interfaceLibs/debug/*.a"
  s.vendored_frameworks = "interfaceLibs/framework/*.frameworks"
end
