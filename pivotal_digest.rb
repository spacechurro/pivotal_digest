#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

require 'pivotal-tracker'
require 'pry'

token = ENV['TOKEN']
project_id = ENV['PROJECT_ID']
owners = ENV['OWNERS'].split(',')

PivotalTracker::Client.token = token
project = PivotalTracker::Project.find(project_id)

owners.each do |owner|
  stories = project.stories.all(owner: owner, state: %w(started unstarted))

  story_with_correct_owner = stories.find { |s| s.owned_by[0].downcase == owner[0] }

  puts "## #{story_with_correct_owner.owned_by}\n\n"

  in_progress = project.stories.all(owner: owner, state: 'started')
  unstarted = project.stories.all(owner: owner, state: 'unstarted')

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

