Pod::Spec.new do |spec|
  spec.name = 'BitcoinCashKit'
  spec.version = '0.2.1'
  spec.summary = 'Bitcoin cash protocol toolkit for Swift'
  spec.description = <<-DESC
                       The BitcoinCashKit library is a Swift implementation of the Bitcoin cash protocol. This library is a fork of Katsumi Kishikawa's original BitcoinKit library aimed at supporting the Bitcoin cash eco-system. It allows maintaining a wallet and sending/receiving transactions without needing a full blockchain node. It comes with a simple wallet app showing how to use it.
                       ```
                    DESC
  spec.homepage = 'https://github.com/BitcoinCashKit/BitcoinCashKit'
  spec.license = { :type => 'MIT', :file => 'LICENSE' }
  spec.author = { 'BitcoinCashKit developers' => 'usatie@yenom.tech' }

  spec.requires_arc = true
  spec.source = { git: 'https://github.com/BitcoinCashKit/BitcoinCashKit.git', tag: "v#{spec.version}" }
  spec.source_files = 'BitcoinCashKit/**/*.{h,m,swift}'
  spec.private_header_files = 'BitcoinCashKit/**/BitcoinCashKitPrivate.h'
  spec.module_map = 'BitcoinCashKit/BitcoinCashKit.modulemap'
  spec.ios.deployment_target = '8.0'
  spec.swift_version = '4.1'

  spec.pod_target_xcconfig = { 'SWIFT_WHOLE_MODULE_OPTIMIZATION' => 'YES',
                               'APPLICATION_EXTENSION_API_ONLY' => 'YES',
                               'SWIFT_INCLUDE_PATHS' => '${PODS_ROOT}/BitcoinCashKit/Libraries',
                               'HEADER_SEARCH_PATHS' => '"${PODS_ROOT}/BitcoinCashKit/Libraries/openssl/include" "${PODS_ROOT}/BitcoinCashKit/Libraries/secp256k1/include"',
                               'LIBRARY_SEARCH_PATHS' => '"${PODS_ROOT}/BitcoinCashKit/Libraries/openssl/lib" "${PODS_ROOT}/BitcoinCashKit/Libraries/secp256k1/lib"' }
  spec.preserve_paths = ['setup', 'Libraries']
  spec.prepare_command = 'sh setup/build_libraries.sh'
end
