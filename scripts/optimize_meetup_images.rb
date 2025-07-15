#!/usr/bin/env ruby

require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  gem 'mini_magick'
end

require 'fileutils'
require 'mini_magick'

MEETUPS_DIR = File.join(__dir__, '..', 'assets', 'images', 'meetups')
SUPPORTED_FORMATS = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.tiff', '.webp'].freeze
MAX_WIDTH = 1200
MAX_HEIGHT = 800
QUALITY = 85

def find_event_folders
  return [] unless Dir.exist?(MEETUPS_DIR)
  
  Dir.glob(File.join(MEETUPS_DIR, '*')).select do |path|
    Dir.exist?(path) && File.basename(path).match?(/^\d{4}-\d{2}-\d{2}-/)
  end
end

def find_images_in_folder(folder_path)
  return [] unless Dir.exist?(folder_path)
  
  Dir.glob(File.join(folder_path, '*')).select do |file|
    File.file?(file) && SUPPORTED_FORMATS.include?(File.extname(file).downcase) && !file.match?(/photo_\d{3}\.jpg$/)
  end
end

def optimize_image(input_path, output_path)
  puts "  Optimizing: #{File.basename(input_path)}"
  
  image = MiniMagick::Image.open(input_path)
  
  # Get original dimensions
  original_width = image.width
  original_height = image.height
  
  # Calculate new dimensions while maintaining aspect ratio
  if original_width > MAX_WIDTH || original_height > MAX_HEIGHT
    ratio = [MAX_WIDTH.to_f / original_width, MAX_HEIGHT.to_f / original_height].min
    new_width = (original_width * ratio).round
    new_height = (original_height * ratio).round
    
    puts "    Resizing from #{original_width}x#{original_height} to #{new_width}x#{new_height}"
    image.resize "#{new_width}x#{new_height}"
  end
  
  # Set quality and format
  image.format 'jpg'
  image.quality QUALITY
  
  # Strip metadata to reduce file size
  image.strip
  
  # Save optimized image
  image.write output_path
  
  # Get file sizes for comparison
  original_size = File.size(input_path)
  optimized_size = File.size(output_path)
  reduction = ((original_size - optimized_size).to_f / original_size * 100).round(1)
  
  puts "    Size: #{format_bytes(original_size)} → #{format_bytes(optimized_size)} (#{reduction}% reduction)"
end

def format_bytes(bytes)
  if bytes >= 1_048_576
    "#{(bytes / 1_048_576.0).round(1)}MB"
  elsif bytes >= 1024
    "#{(bytes / 1024.0).round(1)}KB"
  else
    "#{bytes}B"
  end
end

def process_event_folder(folder_path)
  event_name = File.basename(folder_path)
  puts "\nProcessing event: #{event_name}"
  
  images = find_images_in_folder(folder_path)
  
  if images.empty?
    puts "  No images found in #{event_name}"
    return
  end
  
  puts "  Found #{images.length} images"
  
  # Sort images by filename for consistent numbering
  images.sort!
  
  if images.empty?
    puts "  All images already optimized"
    return
  end

  images.each_with_index do |image_path, index|
    # Generate uniform filename: photo_001.jpg, photo_002.jpg, etc.
    new_filename = "photo_#{(index + 1).to_s.rjust(3, '0')}.jpg"
    output_path = File.join(folder_path, new_filename)
    
    # Skip if this would overwrite an existing optimized image
    if File.exist?(output_path)
      puts "  Skipping: #{File.basename(image_path)} (#{new_filename} already exists)"
      next
    end
    
    begin
      optimize_image(image_path, output_path)
      
      # Delete original since we created a new optimized version
      File.delete(image_path)
      puts "    Deleted original: #{File.basename(image_path)}"
      
    rescue => e
      puts "    Error processing #{File.basename(image_path)}: #{e.message}"
    end
  end
  
  puts "  Completed processing #{event_name}"
end

def optimize_meetup_images
  puts "RubyZG Meetup Image Optimizer"
  puts "=" * 40
  
  unless system('which convert > /dev/null 2>&1')
    puts "Error: ImageMagick is not installed."
    puts "Please install ImageMagick:"
    puts "  Ubuntu/Debian: sudo apt-get install imagemagick"
    puts "  macOS: brew install imagemagick"
    puts "  Arch Linux: sudo pacman -S imagemagick"
    exit 1
  end
  
  event_folders = find_event_folders
  
  if event_folders.empty?
    puts "No event folders found in #{MEETUPS_DIR}"
    puts "Looking for folders with pattern: YYYY-MM-DD-*"
    exit 0
  end
  
  puts "Found #{event_folders.length} event folders:"
  event_folders.each { |folder| puts "  - #{File.basename(folder)}" }
  
  total_start_time = Time.now
  
  event_folders.each do |folder_path|
    folder_start_time = Time.now
    process_event_folder(folder_path)
    folder_duration = Time.now - folder_start_time
    puts "  Processing time: #{folder_duration.round(2)}s"
  end
  
  total_duration = Time.now - total_start_time
  puts "\n" + "=" * 40
  puts "Optimization completed in #{total_duration.round(2)}s"
  puts "All images have been optimized and renamed with uniform naming."
end

# Run the optimization if this script is executed directly
if __FILE__ == $0
  optimize_meetup_images
end