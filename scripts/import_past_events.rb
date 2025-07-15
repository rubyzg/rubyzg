#!/usr/bin/env ruby

require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  gem 'json'
end

require 'net/http'
require 'uri'
require 'fileutils'
require 'time'
require 'json'

API_URL = "https://www.meetup.com/gql2"

def fetch_past_events(before_datetime = Time.now.iso8601, cursor = nil)
  uri = URI(API_URL)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true

  # Build GraphQL query for past events
  variables = {
    "urlname" => "rubyzg",
    "beforeDateTime" => before_datetime
  }
  variables["after"] = cursor if cursor

  payload = {
    "operationName" => "getPastGroupEvents",
    "variables" => variables,
    "extensions" => {
      "persistedQuery" => {
        "version" => 1,
        "sha256Hash" => "fe7abccb7f952c57729a6a8de13c90ee2bd7bbce38bc5ea3f8e4d0052aa95269"
      }
    }
  }

  request = Net::HTTP::Post.new(uri)
  request['Content-Type'] = 'application/json'
  request.body = payload.to_json

  response = http.request(request)
  
  if response.code != '200'
    raise "HTTP Error: #{response.code} - #{response.message}"
  end

  JSON.parse(response.body)
end

def fetch_event_details(event_id)
  uri = URI(API_URL)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true

  payload = {
    "operationName" => "getEventById",
    "variables" => {
      "eventId" => event_id
    },
    "extensions" => {
      "persistedQuery" => {
        "version" => 1,
        "sha256Hash" => "event-detail-hash" # You'll need the actual hash
      }
    }
  }

  request = Net::HTTP::Post.new(uri)
  request['Content-Type'] = 'application/json'
  request.body = payload.to_json

  response = http.request(request)
  
  if response.code == '200'
    JSON.parse(response.body)
  else
    puts "Warning: Could not fetch details for event #{event_id}"
    nil
  end
end

def parse_events_from_response(response)
  events = []
  
  return events unless response.dig('data', 'groupByUrlname', 'events', 'edges')
  
  response['data']['groupByUrlname']['events']['edges'].each do |edge|
    event_node = edge['node']
    
    # Parse venue information
    venue_name = nil
    venue_address = nil
    
    if event_node['venue']
      venue_name = event_node['venue']['name']
      if event_node['venue']['address'] && event_node['venue']['city']
        venue_address = "#{event_node['venue']['address']}, #{event_node['venue']['city']}"
      elsif event_node['venue']['address']
        venue_address = event_node['venue']['address']
      elsif event_node['venue']['city']
        venue_address = event_node['venue']['city']
      end
    end
    
    events << {
      id: event_node['id'],
      title: event_node['title'],
      description: event_node['description'],
      date_time: event_node['dateTime'],
      event_url: event_node['eventUrl'],
      venue_name: venue_name,
      venue_address: venue_address,
      featured_photo: event_node.dig('featuredEventPhoto', 'source')
    }
  end
  
  events
end

def format_event_for_jekyll(event)
  return nil unless event[:title] && event[:date_time]

  begin
    date = Time.parse(event[:date_time])
  rescue
    puts "Warning: Could not parse date for event #{event[:id]}: #{event[:date_time]}"
    return nil
  end

  date_string = date.strftime('%Y-%m-%d')

  # Create filename from date and title
  title_slug = event[:title]
    .downcase
    .gsub(/[^a-z0-9\s-]/, '')
    .gsub(/\s+/, '-')
    .gsub(/-+/, '-')
    .strip

  filename = "#{date_string}-#{title_slug}.md"

  # Build frontmatter
  frontmatter_lines = [
    "---",
    "layout: event",
    "ical_uid: \"event_#{event[:id]}@meetup.com\"",
    "title: \"#{(event[:title] || '').gsub('"', '\"')}\"",
    "date: #{date.iso8601}",
    "event_url: \"#{event[:event_url] || ''}\""
  ]

  # Add venue and address
  if event[:venue_name] && !event[:venue_name].empty?
    frontmatter_lines << "venue: \"#{event[:venue_name]}\""
  else
    frontmatter_lines << "venue:"
  end

  if event[:venue_address] && !event[:venue_address].empty?
    frontmatter_lines << "address: \"#{event[:venue_address]}\""
  else
    frontmatter_lines << "address:"
  end

  # Add photos array with featured photo if available
  if event[:featured_photo]
    frontmatter_lines << "pictures:"
    frontmatter_lines << "  - url: \"#{event[:featured_photo]}\""
    frontmatter_lines << "    caption: \"#{event[:title]}\""
  else
    frontmatter_lines << "pictures: []"
  end
  
  frontmatter_lines += [
    "videos: []",
    "---",
    ""
  ]

  # Clean up description
  description = event[:description] || ''
  description = description.gsub(/^Ruby Zagreb\s*/, '') # Remove "Ruby Zagreb" prefix
  description = description.gsub(/\r\n|\r/, "\n") # Normalize line breaks
  
  # Convert single line breaks to markdown line breaks
  description = description.gsub(/\n(?!\n)/, "  \n")
  
  frontmatter_lines << description

  front_matter = frontmatter_lines.join("\n")

  { filename: filename, content: front_matter }
end

def import_past_events
  puts 'Fetching past events from Meetup GraphQL API...'
  
  all_events = []
  cursor = nil
  page = 1
  
  loop do
    puts "Fetching page #{page}..."
    response = fetch_past_events(Time.now.iso8601, cursor)
    
    events = parse_events_from_response(response)
    all_events.concat(events)
    
    puts "Found #{events.length} events on page #{page}"
    
    # Check if there are more pages
    page_info = response.dig('data', 'groupByUrlname', 'events', 'pageInfo')
    break unless page_info && page_info['hasNextPage']
    
    cursor = page_info['endCursor']
    page += 1
    
    # Add a small delay to be respectful to the API
    sleep(1)
  end
  
  puts "Total events found: #{all_events.length}"
  
  # Create _events directory if it doesn't exist
  events_dir = File.join(__dir__, '..', '_events')
  FileUtils.mkdir_p(events_dir)
  
  # Get existing event files to avoid duplicates
  existing_files = Dir.glob(File.join(events_dir, '*.md')).map { |f| File.basename(f) }
  
  created_count = 0
  skipped_count = 0
  
  # Process each event
  all_events.each do |event|
    event_data = format_event_for_jekyll(event)
    next unless event_data
    
    filepath = File.join(events_dir, event_data[:filename])
    
    # Skip if file already exists
    if existing_files.include?(event_data[:filename])
      puts "Skipped existing: #{event_data[:filename]}"
      skipped_count += 1
    else
      File.write(filepath, event_data[:content])
      puts "Created: #{event_data[:filename]}"
      created_count += 1
    end
  end
  
  puts "\nImport completed!"
  puts "Created: #{created_count} new events"
  puts "Skipped: #{skipped_count} existing events"
  
rescue => e
  puts "Error importing past events: #{e.message}"
  puts e.backtrace.join("\n")
  exit 1
end

# Run the import if this script is executed directly
if __FILE__ == $0
  import_past_events
end
