Pod::Spec.new do |spec|
  spec.name         = "FlexyNetwork"
  spec.version      = "0.1.0"
  spec.summary      = "iOS Networking Framework for common tasks"
  spec.description  = <<-DESC
iOS Networking Framework for common tasks
                   DESC

  spec.homepage     = "https://github.com/IsaAliev/FlexyNetwork"

  spec.license      = { :type => "MIT", :file => "LICENSE" }

  spec.author       = { "IsaAliev" => "isaaliev12@gmail.com" }

  spec.platform     = :ios, "11.0"

  spec.source       = { :git => "https://github.com/IsaAliev/FlexyNetwork.git", :tag => spec.version }

  spec.source_files  = "FlexyNetwork/**/*.{swift}"

  spec.swift_version = "5.0" 
end
