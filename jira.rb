require 'open-uri'
require 'io/console'

search_url = 'http://jira.corp.uievolution.com/rest/api/2/search?jql=project+=+EXM+AND+status+was+resolved+by+cody+ORDER+BY+updated+DESC'
user = "cody"
puts "Enter JIRA password for #{user}:"
password = STDIN.noecho(&:gets).chomp("\n")
search_data = open(search_url, http_basic_authentication: [user, password]) # fails if not connected to the VPN
puts search_data.read