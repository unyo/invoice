#!/usr/bin/env ruby
require 'active_support/all'
require 'sinatra'
require 'sinatra/reloader'

set :bind, '0.0.0.0'
set :port, 8006

get "/" do
  days = params['days'] ? params['days'].to_i : ((Date.today.day > 15 && !params['full']) ? (Date.today.day - 15) : (Date.today.day))
  puts days
  today_start = Date.today.beginning_of_day - (days - 1).days
  today_end = Date.today.end_of_day - (days - 1).days
  days = Integer(ARGV[0]) if ARGV[0]
  author = "--author \"Cody\"" unless ARGV[1]=='all'
  #projects = ["folio", "shorex", "trident", "admin", "vnext", "ocean-compass"]
  #projects = ["ocean", "trident", "web2", "web"]
  projects = ["kbase"]
  admin_lines = []
  root_path = File.expand_path(Dir.home)
  @days = []
  days.times do |day|
    days_hash = {}
    day_start = today_start.strftime('%FT%T%:z')
    day_end = today_end.strftime('%FT%T%:z')
    days_hash[:day] = today_start.strftime('%F')
    command = "git log --date=local #{author} --since \"#{day_start}\" --until \"#{day_end}\" --pretty=oneline --abbrev-commit"
    days_hash[:projects] = {}
    projects.each do |project|
      project_hash = {}
      directory = File.join(root_path, project)
      Dir.chdir(directory)
      cmd_output = `#{command}`
      split_output = cmd_output.split("\n")
      output_array = []
      split_output.each do |output|
        next if output.include?("Merge branch")
        output_array << output.gsub(/^......./, '-')
      end
      unless output_array.empty?
        project_hash[:lines] = output_array
        days_hash[:projects][project] = project_hash
      end
    end
    if days_hash[:projects]['vnext'] and days_hash[:projects]['admin']
      days_hash[:projects]['vnext'][:lines] -= days_hash[:projects]['admin'][:lines]
      if days_hash[:projects]['vnext'][:lines].empty?
        days_hash[:projects].delete('vnext')
      end
    end
    today_start = today_start + 1.day
    today_end = today_end + 1.day
    unless days_hash[:projects].empty?
      @days << days_hash
    end
  end
  erb :invoice_template
end

# TODO: contenteditable on the invoice fields for easy editing
# TODO: manual add days so we can stop using google docs

__END__

@@invoice_template
<table style="border:none;border-collapse:collapse;width:100%;">
  <colgroup>
    <col width="85" />
    <col width="438" />
    <col width="110" />
    <col width="132" />
  </colgroup>
  <tbody>
    <tr style="height:0px">
      <td style="border-left:solid #efefef 1px;border-right:solid #efefef 1px;border-bottom:solid #efefef 1px;border-top:solid #efefef 1px;vertical-align:top;background-color:#f1f1f2;padding:7px 7px 7px 7px">
        <h1 dir="ltr" style="line-height:1.2;margin-top:0pt;margin-bottom:0pt;margin-left: 0.75pt;"><span style="font-size: 10.6667px; font-family: Arial; color: rgb(126, 128, 118); vertical-align: baseline; white-space: pre-wrap; background-color: transparent;">DATE</span></h1>
      </td>

      <td style="border-left:solid #efefef 1px;border-right:solid #efefef 1px;border-bottom:solid #efefef 1px;border-top:solid #efefef 1px;vertical-align:top;background-color:#f1f1f2;padding:7px 7px 7px 7px">
        <h1 dir="ltr" style="line-height:1.2;margin-top:0pt;margin-bottom:0pt;margin-left: 0.75pt;"><span style="font-size: 10.6667px; font-family: Arial; color: rgb(126, 128, 118); vertical-align: baseline; white-space: pre-wrap; background-color: transparent;">DESCRIPTION OF WORK</span></h1>
      </td>

      <td style="border-left:solid #efefef 1px;border-right:solid #efefef 1px;border-bottom:solid #efefef 1px;border-top:solid #efefef 1px;vertical-align:top;background-color:#f1f1f2;padding:7px 7px 7px 7px"><br /></td>

      <td style="border-left:solid #efefef 1px;border-right:solid #efefef 1px;border-bottom:solid #efefef 1px;border-top:solid #efefef 1px;vertical-align:top;background-color:#f1f1f2;padding:7px 7px 7px 7px">
        <h2 dir="ltr" style="line-height:1.2;margin-top:0pt;margin-bottom:0pt;margin-left: 0.75pt;text-align: right;"><span style="font-size: 10.6667px; font-family: Arial; color: rgb(126, 128, 118); font-weight: 400; vertical-align: baseline; white-space: pre-wrap; background-color: transparent;">QTY</span></h2>
      </td>
    </tr>
    <!-- body start -->
    <% @days.each do |day| %>
    <tr style="height:0px">
      <td style="border-left:solid #efefef 1px;border-right:solid #efefef 1px;border-bottom:solid #efefef 1px;border-top:solid #efefef 1px;vertical-align:top;padding:7px 7px 7px 7px">
        <p dir="ltr" style="line-height:1.2;margin-top:0pt;margin-bottom:0pt;"><span style="font-size: 12px; font-family: Arial; color: rgb(126, 128, 118); vertical-align: baseline; white-space: pre-wrap;"><%= day[:day] %></span></p>
      </td>

      <td style="border-left:solid #efefef 1px;border-right:solid #efefef 1px;border-bottom:solid #efefef 1px;border-top:solid #efefef 1px;vertical-align:top;padding:7px 7px 7px 7px">
        <% day[:projects].each do |key, project| %>
          <p dir="ltr" style="line-height:1.2;margin-top:0pt;margin-bottom:0pt;margin-left: 0.75pt;"><span style="font-size: 12px; font-family: Arial; color: rgb(126, 128, 118); vertical-align: baseline; white-space: pre-wrap;"># <%= key %></span></p>
          <% project[:lines].each do |line| %>
            <p dir="ltr" style="line-height:1.2;margin-top:0pt;margin-bottom:0pt;margin-left: 0.75pt;"><span style="font-size: 12px; font-family: Arial; color: rgb(126, 128, 118); vertical-align: baseline; white-space: pre-wrap;"><%= line %></span></p>
          <% end %>
        <% end %>
      </td>

      <td style="border-left:solid #efefef 1px;border-right:solid #efefef 1px;border-bottom:solid #efefef 1px;border-top:solid #efefef 1px;vertical-align:top;padding:7px 7px 7px 7px"><br /></td>

      <td style="border-left:solid #efefef 1px;border-right:solid #efefef 1px;border-bottom:solid #efefef 1px;border-top:solid #efefef 1px;vertical-align:top;background-color:#f1f1f2;padding:7px 7px 7px 7px">
        <p dir="ltr" style="line-height:1.2;margin-top:0pt;margin-bottom:0pt;margin-left: 0.75pt;text-align: right;"><span style="font-size: 12px; font-family: Arial; color: rgb(126, 128, 118); vertical-align: baseline; white-space: pre-wrap; background-color: transparent;">1 day</span></p>
      </td>
    </tr>
    <% end %>
    <!-- body end -->
    <tr style="height:13px">
      <td style="border-left:solid #efefef 1px;border-right:solid #efefef 1px;border-bottom:solid #efefef 1px;border-top:solid #efefef 1px;vertical-align:top;padding:7px 7px 7px 7px"><br /></td>

      <td style="border-left:solid #efefef 1px;border-right:solid #efefef 1px;border-bottom:solid #efefef 1px;border-top:solid #efefef 1px;vertical-align:top;padding:7px 7px 7px 7px"><br /></td>

      <td style="border-left:solid #efefef 1px;border-right:solid #efefef 1px;border-bottom:solid #efefef 1px;border-top:solid #efefef 1px;vertical-align:top;background-color:#e4e4e6;padding:7px 7px 7px 7px">
        <h1 dir="ltr" style="line-height:1.2;margin-top:0pt;margin-bottom:0pt;margin-left: 0.75pt;text-align: right;"><span style="font-size: 13.3333px; font-family: Arial; color: rgb(126, 128, 118); vertical-align: baseline; white-space: pre-wrap; background-color: transparent;">TOTAL UNITS</span></h1>
      </td>

      <td style="border-left:solid #efefef 1px;border-right:solid #efefef 1px;border-bottom:solid #efefef 1px;border-top:solid #efefef 1px;vertical-align:top;background-color:#e4e4e6;padding:7px 7px 7px 7px">
        <p dir="ltr" style="line-height:1.2;margin-top:0pt;margin-bottom:0pt;margin-left: 0.75pt;text-align: right;"><span style="font-size: 13.3333px; font-family: Arial; color: rgb(126, 128, 118); vertical-align: baseline; white-space: pre-wrap; background-color: transparent;">2 weeks</span></p>
      </td>
    </tr>

    <tr style="height:13px">
      <td style="border-left:solid #efefef 1px;border-right:solid #efefef 1px;border-bottom:solid #efefef 1px;border-top:solid #efefef 1px;vertical-align:top;padding:7px 7px 7px 7px"><br /></td>

      <td style="border-left:solid #efefef 1px;border-right:solid #efefef 1px;border-bottom:solid #efefef 1px;border-top:solid #efefef 1px;vertical-align:top;padding:7px 7px 7px 7px"><br /></td>

      <td style="border-left:solid #efefef 1px;border-right:solid #efefef 1px;border-bottom:solid #efefef 1px;border-top:solid #efefef 1px;vertical-align:top;background-color:#e4e4e6;padding:7px 7px 7px 7px">
        <h1 dir="ltr" style="line-height:1.2;margin-top:0pt;margin-bottom:0pt;margin-left: 0.75pt;text-align: right;"><span style="font-size: 13.3333px; font-family: Arial; color: rgb(126, 128, 118); vertical-align: baseline; white-space: pre-wrap; background-color: transparent;">UNIT PRICE</span></h1>
      </td>

      <td style="border-left:solid #efefef 1px;border-right:solid #efefef 1px;border-bottom:solid #efefef 1px;border-top:solid #efefef 1px;vertical-align:top;background-color:#e4e4e6;padding:7px 7px 7px 7px">
        <p dir="ltr" style="line-height:1.2;margin-top:0pt;margin-bottom:0pt;margin-left: 0.75pt;text-align: right;"><span style="font-size: 13.3333px; font-family: Arial; color: rgb(126, 128, 118); vertical-align: baseline; white-space: pre-wrap; background-color: transparent;">$5,833.33/mo</span></p>
      </td>
    </tr>

    <tr style="height:0px">
      <td style="border-left:solid #efefef 1px;border-right:solid #efefef 1px;border-bottom:solid #efefef 1px;border-top:solid #efefef 1px;vertical-align:top;padding:7px 7px 7px 7px"><br /></td>

      <td style="border-left:solid #efefef 1px;border-right:solid #efefef 1px;border-bottom:solid #efefef 1px;border-top:solid #efefef 1px;vertical-align:top;padding:7px 7px 7px 7px"><br /></td>

      <td style="border-left:solid #efefef 1px;border-right:solid #efefef 1px;border-bottom:solid #efefef 1px;border-top:solid #efefef 1px;vertical-align:top;background-color:#e4e4e6;padding:7px 7px 7px 7px">
        <h1 dir="ltr" style="line-height:1.2;margin-top:0pt;margin-bottom:0pt;margin-left: 0.75pt;text-align: right;"><span style="font-size: 13.3333px; font-family: Arial; color: rgb(126, 128, 118); vertical-align: baseline; white-space: pre-wrap; background-color: transparent;">GRAND TOTAL</span></h1>
      </td>

      <td style="border-left:solid #efefef 1px;border-right:solid #efefef 1px;border-bottom:solid #efefef 1px;border-top:solid #efefef 1px;vertical-align:top;background-color:#e4e4e6;padding:7px 7px 7px 7px">
        <p dir="ltr" style="line-height:1.2;margin-top:0pt;margin-bottom:0pt;margin-left: 0.75pt;text-align: right;"><span style="font-size: 13.3333px; font-family: Arial; color: rgb(126, 128, 118); vertical-align: baseline; white-space: pre-wrap; background-color: transparent;">$2,916.66</span></p>
      </td>
    </tr>
  </tbody>
</table>
