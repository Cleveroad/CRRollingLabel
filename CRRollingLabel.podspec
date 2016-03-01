Pod::Spec.new do |s|
  s.name             = "CRRollingLabel"
  s.version          = "0.0.1"
  s.summary          = "CRRollingLabel provides an animated text change, as a scrolling column. CRRollingLabel inherits of UILabel, It supports all functions of UILabel without any additional configuration, but limited to display only numeric values."

  s.description      = <<-DESC
CRRollingLabel provides an animated text change, as a scrolling column, but have some limitations. The CRRollingLabel is currently support only one line of text and is currently limited to work only with numerical values. Non-numeric values are ignored. The CRRollingLabel currently not working properly with attributedText with different fonts, placed in one NSAttributedString. The NSLineBreakMode is currently not working properly. Please, use autoshrink instead to achieve the result.
                       DESC

  s.homepage         = "https://github.com/Cleveroad/CRRollingLabel"
  s.license          = 'MIT'
  s.author           = { "Prokopiev Nick" => "prokopiev.cr@gmail.com" }
  s.source           = { :git => "https://github.com/Cleveroad/CRRollingLabel.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.private_header_files = 'Pod/CATextLayer+RollingLabelLayerText.h'
  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'CRRollingLabel' => ['Pod/Assets/*.png']
  }

end
