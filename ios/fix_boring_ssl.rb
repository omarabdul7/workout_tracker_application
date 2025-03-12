#!/usr/bin/env ruby

require 'xcodeproj'

project_path = 'Pods/Pods.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Find the BoringSSL-GRPC target
boring_ssl_target = project.targets.find { |target| target.name == 'BoringSSL-GRPC' }

if boring_ssl_target
  puts "Found BoringSSL-GRPC target"
  
  # Iterate through all the build configurations
  boring_ssl_target.build_configurations.each do |config|
    puts "Checking configuration: #{config.name}"
    
    # Completely clear the problematic flags
    config.build_settings['OTHER_CFLAGS'] = ''
    config.build_settings['OTHER_CPLUSPLUSFLAGS'] = ''
    
    # Remove -G from preprocessing definitions if present
    if config.build_settings['GCC_PREPROCESSOR_DEFINITIONS']
      definitions = config.build_settings['GCC_PREPROCESSOR_DEFINITIONS']
      if definitions.is_a?(Array)
        config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] = definitions.reject { |flag| flag.include?('-G') }
      end
    end
    
    # Add a new definition for OPENSSL_NO_ASM without -G
    if config.build_settings['GCC_PREPROCESSOR_DEFINITIONS']
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] << 'OPENSSL_NO_ASM=1'
    else
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] = ['OPENSSL_NO_ASM=1']
    end
    
    puts "Updated build settings for #{config.name}"
  end
  
  # Iterate through all the files in the target and remove any settings with -G flag
  boring_ssl_target.source_build_phase.files.each do |build_file|
    if build_file.settings && build_file.settings['COMPILER_FLAGS']
      if build_file.settings['COMPILER_FLAGS'].include?('-G')
        build_file.settings['COMPILER_FLAGS'] = build_file.settings['COMPILER_FLAGS'].gsub(/-G\s*/, '')
        puts "Removed -G flag from file: #{build_file.file_ref.path}"
      end
    end
  end
  
  project.save
  puts "Project saved successfully"
else
  puts "BoringSSL-GRPC target not found"
end 