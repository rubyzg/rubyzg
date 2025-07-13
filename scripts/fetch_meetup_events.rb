#!/usr/bin/env ruby

require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  gem 'icalendar'
end

require 'net/http'
require 'uri'
require 'fileutils'
require 'time'
require 'icalendar'

ICAL_URL = 'https://www.meetup.com/rubyzg/events/ical/'

def download_ical
  uri = URI(ICAL_URL)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true

  request = Net::HTTP::Get.new(uri)
  response = http.request(request)

  if response.code != '200'
    raise "HTTP Error: #{response.code} - #{response.message}"
  end

  response.body
end

def parse_ical(ical_content)
  calendars = Icalendar::Calendar.parse(ical_content)
  events = []

  calendars.each do |calendar|
    calendar.events.each do |event|
      events << {
        title: event.summary&.to_s,
        description: event.description&.to_s,
        start_time: event.dtstart&.to_time,
        end_time: event.dtend&.to_time,
        location: event.location&.to_s,
        url: event.url&.to_s,
        uid: event.uid&.to_s
      }
    end
  end

  events
end

def format_event_for_jekyll(event)
  return nil unless event[:title] && event[:start_time]

  date = event[:start_time]
  date_string = date.strftime('%Y-%m-%d')

  # Create filename from date and title
  title_slug = event[:title]
    .downcase
    .gsub(/[^a-z0-9\s-]/, '')
    .gsub(/\s+/, '-')
    .gsub(/-+/, '-')
    .strip

  filename = "#{date_string}-#{title_slug}.md"

  # Extract venue and address from location
  venue = nil
  address = nil

  if event[:location] && !event[:location].empty?
    location = event[:location].strip

    # Common patterns for Meetup location formats:
    # "Venue Name, Street Address, City"
    # "Venue Name (Company), Street Address, City"
    # "Street Address, City"
    # "Venue Name"

    if location.include?(',')
      parts = location.split(',').map(&:strip)

      if parts.length >= 3
        # Format: "Venue Name, Street Address, City"
        venue = parts[0]
        address = parts[1..-1].join(', ')
      elsif parts.length == 2
        # Could be "Venue Name, City" or "Street Address, City"
        if parts[0].match?(/\d/) # Contains numbers, likely an address
          venue = nil
          address = location
        else
          venue = parts[0]
          address = parts[1]
        end
      end
    else
      # Single part - could be venue name or address
      if location.match?(/\d/) # Contains numbers, likely an address
        venue = nil
        address = location
      else
        venue = location
        address = nil
      end
    end

    # Clean up venue name - remove parenthetical company names
    venue = venue.gsub(/\s*\([^)]+\)/, '').strip if venue
  end

  # Build frontmatter with conditional fields
  frontmatter_lines = [
    "---",
    "layout: event",
    "ical_uid: \"#{event[:uid] || ''}\"",
    "title: \"#{event[:title].gsub('"', '\"')}\"",
    "date: #{event[:start_time].iso8601}",
    "event_url: \"#{event[:url] || ''}\""
  ]

  # Add venue and address only if they have values
  if venue && !venue.empty?
    frontmatter_lines << "venue: \"#{venue}\""
  else
    frontmatter_lines << "venue:"
  end

  if address && !address.empty?
    frontmatter_lines << "address: \"#{address}\""
  else
    frontmatter_lines << "address:"
  end

  frontmatter_lines += [
    "pictures: []",
    "videos: []",
    "---",
    ""
  ]

  # Clean up description - remove "Ruby Zagreb" prefix and fix formatting
  description = event[:description] || ''
  description = description.gsub(/^Ruby Zagreb\s*/, '') # Remove "Ruby Zagreb" prefix
  description = description.gsub(/\r\n|\r/, "\n") # Normalize line breaks
  
  # Convert single line breaks to markdown line breaks (add two spaces)
  # but preserve paragraph breaks (double line breaks)
  description = description.gsub(/\n(?!\n)/, "  \n")
  
  frontmatter_lines << description

  front_matter = frontmatter_lines.join("\n")

  { filename: filename, content: front_matter }
end

def update_events_from_ical
  puts 'Downloading iCal file from Meetup...'
  ical_content = download_ical

  puts 'Parsing iCal events...'
  events = parse_ical(ical_content)

  # Import ALL events (not just upcoming)
  all_events = events.select { |event| event[:start_time] }

  puts "Found #{all_events.length} events"

  events_dir = File.join(__dir__, '..', '_events')

  # Create _events directory if it doesn't exist
  FileUtils.mkdir_p(events_dir)

  # Get existing event files to avoid duplicates
  existing_files = Dir.glob(File.join(events_dir, '*.md')).map { |f| File.basename(f) }

  # Create new event files (skip if already exists)
  all_events.each do |event|
    event_data = format_event_for_jekyll(event)
    next unless event_data

    filepath = File.join(events_dir, event_data[:filename])

    # Skip if file already exists
    if existing_files.include?(event_data[:filename])
      puts "Skipped existing: #{event_data[:filename]}"
    else
      File.write(filepath, event_data[:content])
      puts "Created: #{event_data[:filename]}"
    end
  end

  puts 'Events updated successfully from iCal!'
rescue => e
  puts "Error updating events from iCal: #{e.message}"
  exit 1
end

update_events_from_ical
