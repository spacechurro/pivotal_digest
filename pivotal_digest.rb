#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

# require 'pivotal-tracker'
require 'tracker_api'
require 'pry'

token = ENV['TOKEN']
project_id = ENV['PROJECT_ID']
owners = ENV['OWNERS'].split(',')

client = TrackerApi::Client.new(token: token)

project = client.project(project_id)

# client-side env var defines these... we don't derive them from the api... ?
# ['dh', 'sr']
owners.each do |owner|


  # get all the started and unstarted Stories for this owner
  stories = project.stories(filter: "owner:#{owner} state:started,unstarted")

  # refine the stories list... for those stories with multiple owners, whoever is first... that's who gets it in their queue for the email... 
  # FIXME: make this work again if we need it?
  # story_with_correct_owner = stories.find { |s| s.owned_by[0].downcase == owner[0] }

  # if the first owner in the Story object is not the current owner... well then let's just stop right here... not printing anything!
  # FIXME: put this back if we still need it.
  # next unless story_with_correct_owner

  # print out owner the name?  or the initials?
  # puts "## #{story_with_correct_owner.owned_by}\n\n"
  person = project.memberships.map(&:person).find { |person| person.initials.downcase == owner }
  puts "## #{person.name}"

  # get all their in_progress stories together for printing
  in_progress = project.stories.all(owner: owner, state: 'started')

  # get all their unstarted stories together for printing.
  unstarted = project.stories.all(owner: owner, state: 'unstarted')

  ## print out the story name, and the url.
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
