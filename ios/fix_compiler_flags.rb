#!/usr/bin/env ruby

require 'xcodeproj'

def fix_flags(xcodeproj_path)
  project = Xcodeproj::Project.open(xcodeproj_path)
  project.targets.each do |target|
    target.build_configurations.each do |config|
      # Remove problematic flags
      config.build_settings['OTHER_CFLAGS'] = ''
      config.build_settings['OTHER_CPLUSPLUSFLAGS'] = ''
    end
  end
  project.save
  puts "Successfully removed problematic compiler flags from #{xcodeproj_path}"
end

if ARGV.length != 1
  puts "Usage: ruby fix_compiler_flags.rb <path_to_xcodeproj>"
  exit 1
end

fix_flags(ARGV[0]) 