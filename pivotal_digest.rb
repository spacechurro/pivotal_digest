#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

require 'tracker_api'
require 'pry'

token = ENV['TOKEN']
project_id = ENV['PROJECT_ID']
owners = ENV['OWNERS'].split(',')

project = TrackerApi::Client.new(token: token).project(project_id)

owners.each do |owner|
  stories = project.stories(filter: "owner:#{owner} state:started,unstarted")

  # story_with_correct_owner = stories.find { |s| s.owned_by[0].downcase == owner[0] }

  # next unless story_with_correct_owner

  person = project.memberships.map(&:person).find { |person| person.initials.downcase == owner }
  puts "## #{person.name}"

  in_progress = stories.select { |story| story.current_state == 'started' }
  unstarted = stories.select { |story| story.current_state == 'unstarted' }

  unless in_progress.empty?
    puts "### In progress\n\n"
    in_progress.each do |story|
      puts "#{story.name}  "
      puts "#{story.url}\n\n"
    end
  end

  unless unstarted.empty?
    puts "### Unstarted\n\n"
    unstarted.each do |story|
      puts "#{story.name}  "
      puts "#{story.url}\n\n"
    end
  end

  puts "\n"
end
