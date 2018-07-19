#!/usr/bin/env ruby
require 'active_support/all'
days = 14
today_start = Date.today.beginning_of_day - (days - 1).days
today_end = Date.today.end_of_day - (days - 1).days
days = Integer(ARGV[0]) if ARGV[0]
author = "--author \"Cody\"" unless ARGV[1]=='all'
projects = ["folio", "shorex", "trident", "vnext"]#, "admin"]
root_path = File.expand_path(File.dirname(__FILE__))
days.times do |day|
  day_start = today_start.strftime('%FT%T%:z')
  day_end = today_end.strftime('%FT%T%:z')
  puts "[#{today_start.strftime('%F')}]"
  command = "git log --date=local #{author} --since \"#{day_start}\" --until \"#{day_end}\" --pretty=oneline --abbrev-commit"
  projects.each do |project|
    directory = File.join(root_path, project)
    Dir.chdir(directory)
    cmd_output = `#{command}`
    split_output = cmd_output.split("\n")
    output_string = ""
    split_output.each do |output|
      next if output.include?("Merge branch")
      output_string << output.gsub(/^......./, '-') << "\n"
    end
    unless output_string==""
      puts "# #{project}"
      puts output_string
    end
  end
  puts ""
  today_start = today_start + 1.day
  today_end = today_end + 1.day
end