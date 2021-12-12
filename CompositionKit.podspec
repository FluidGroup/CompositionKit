Pod::Spec.new do |spec|
  spec.name = "CompositionKit"
  spec.version = "0.1.0"
  spec.summary = "Tools for compositional view hierarchy"
  spec.description = <<-DESC
  set of compositional components
                   DESC

  spec.homepage = "https://github.com/muukii/CompositionKit"
  spec.license = "MIT"
  spec.author = { "Muukii" => "muukii.app@gmail.com" }
  spec.social_media_url = "https://twitter.com/muukii_app"

  spec.ios.deployment_target = "12.0"
  # spec.osx.deployment_target = "10.7"
  # spec.watchos.deployment_target = "2.0"
  # spec.tvos.deployment_target = "9.0"

  spec.source = { :git => "https://github.com/muukii/CompositionKit.git", :tag => "#{spec.version}" }
  spec.source_files = "CompositionKit/**/*.swift"  
  spec.framework = "UIKit"
  spec.requires_arc = true
  spec.dependency "MondrianLayout", ">= 0.5.0"
  spec.swift_versions = ["5.3", "5.4", "5.5"]
end
