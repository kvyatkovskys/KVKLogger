Pod::Spec.new do |spec|
  spec.name         = "KVKLogger"
  spec.version      = "0.2.15"
  spec.summary      = "Save logs to local DB on applications"

  spec.description  = <<-DESC
                   DESC

  spec.homepage     = "https://github.com/kvyatkovskys/KVKLogger"
  spec.license      = { :type => 'MIT', :file => 'LICENSE.md' }
  spec.author       = { "Kviatkovskii Sergei" => "sergejkvyatkovskij@gmail.com" }
  spec.source       = { :git => "https://github.com/kvyatkovskys/KVKLogger.git", :tag => "#{spec.version}" }
  spec.ios.deployment_target = '15.0'
  spec.swift_version    = '5.0'
  spec.source_files = "Sources", "Sources/**/*.swift"
  spec.social_media_url = 'https://github.com/kvyatkovskys'

end
