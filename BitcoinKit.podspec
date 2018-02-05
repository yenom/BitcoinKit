Pod::Spec.new do |spec|
  spec.name = 'BitcoinKit'
  spec.version = '0.1.0'
  spec.summary = 'Bitcoin protocol toolkit for Swift'
  spec.description = <<-DESC
                       BitcoinKit implements Bitcoin protocol in Swift. It is an implementation of the Bitcoin SPV protocol written (almost) entirely in swift.
                       ```
                    DESC
  spec.homepage = 'https://github.com/kishikawakatsumi/BitcoinKit'
  spec.license = { :type => 'Apache 2.0', :file => 'LICENSE' }
  spec.author = { 'Kishikawa Katsumi' => 'kishikawakatsumi@mac.com' }
  spec.social_media_url = 'https://twitter.com/k_katsumi'

  spec.requires_arc = true
  spec.source = { git: 'https://github.com/kishikawakatsumi/BitcoinKit.git', tag: "v#{spec.version}" }
  spec.source_files = 'BitcoinKit/*.{h,swift}'

  spec.pod_target_xcconfig = { 'SWIFT_WHOLE_MODULE_OPTIMIZATION' => 'YES',
                               'APPLICATION_EXTENSION_API_ONLY' => 'YES' }

  spec.ios.deployment_target = '8.0'

  spec.preserve_paths = './setup'
  spec.prepare_command = 'sh ./setup/build_libraries.sh'
end
