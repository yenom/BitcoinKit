Pod::Spec.new do |spec|
  spec.name = 'BitcoinKit'
  spec.version = '0.1.2'
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
  spec.source_files = 'BitcoinKit/**/*.{h,m,swift}'
  spec.private_header_files = 'BitcoinKit/**/BitcoinKitInternal.h'
  spec.module_map = 'BitcoinKit/BitcoinKit.modulemap'
  spec.ios.deployment_target = '8.0'
  spec.swift_version = '4.0'

  spec.pod_target_xcconfig = { 'SWIFT_WHOLE_MODULE_OPTIMIZATION' => 'YES',
                               'APPLICATION_EXTENSION_API_ONLY' => 'YES',
                               'SWIFT_INCLUDE_PATHS' => '${PODS_ROOT}/BitcoinKit/Libraries',
                               'HEADER_SEARCH_PATHS' => '"${PODS_ROOT}/BitcoinKit/Libraries/openssl/include" "${PODS_ROOT}/BitcoinKit/Libraries/secp256k1/include"',
                               'LIBRARY_SEARCH_PATHS' => '"${PODS_ROOT}/BitcoinKit/Libraries/openssl/lib" "${PODS_ROOT}/BitcoinKit/Libraries/secp256k1/lib"' }
  spec.preserve_paths = ['setup', 'Libraries']
  spec.prepare_command = 'sh setup/build_libraries.sh'
end
