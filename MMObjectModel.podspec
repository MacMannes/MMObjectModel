Pod::Spec.new do |spec|
  spec.name         = 'MMObjectModel.podspec'
  spec.version      = '0.0.1'
  spec.summary      = "Handy superclass for mapping JSON or XML data to model classes"
  spec.homepage     = "https://github.com/MacMannes/MMObjectModel"
  spec.author       = { "André Mathlener" => "info@macmannes.nl" }
  spec.source       = { :git => "https://github.com/MacMannes/MMObjectModel.git"  }
  spec.ios.deployment_target = '5.0'
  spec.source_files = 'MMObjectModel/*.{h,m}'
  spec.license      = 'MIT'
  spec.requires_arc = true
end
