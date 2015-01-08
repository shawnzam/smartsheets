#!/usr/bin/env ruby
=begin
  Smartsheet Platform sample code
  Hello Smartsheet (Ruby)
   Copyright 2013 Smartsheet, Inc.
   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at
       http://www.apache.org/licenses/LICENSE-2.0
   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
=end

# load third-party libraries and extensions
require 'httparty'
require 'active_support/core_ext/hash/deep_merge'
require 'json'

# define httparty class
class Smartsheet
  include HTTParty
  base_uri 'https://api.smartsheet.com/1.1'
 
  # initialize httparty object
  def initialize(token)
    @auth_options = {headers: {"Authorization" => 'Bearer ' + token}}
  end

  def request(method, uri, options={})
    # merge headers
    options.deep_merge!(@auth_options)

    # process response
    puts "* requesting #{method.upcase} #{uri}"
    response = self.class.send(method, uri, options)
    json = JSON.parse(response.body)

    # if response is anything other than HTTP 200, print error and quit
    if response.code.to_s !~ /^2/
      puts "* fatal error: #{json['errorCode']}: #{json['message']}"
      exit 
    end

    return json
  end
end

puts
puts "STARTING HelloSmartsheet..."
puts
print "Please enter Smartsheet API access token: "
ss_token = gets.strip
# initializing Smartsheet connection object
ss_connection = Smartsheet.new(ss_token)
puts
puts "Fetching list of your sheets..."
sheets = ss_connection.request('get', '/sheets') 

if sheets.length == 0
  puts "You don't have any sheets. Goodbye!"
  exit
end

puts "Total sheets: #{sheets.length}"

puts "Showing the first five sheets:"
sheets.each_with_index do |s, i|
  break if i > 4
  puts "#{i+1}: #{s['name']}"
end

print "Enter the number of the sheet you want to share: "
sheet_num_to_share = gets.strip

puts

# convert ordinal number to array index
sheet_index_to_share = sheet_num_to_share.to_i - 1

print "Enter an email address to share #{sheets[sheet_index_to_share]['name']} to: "
email_to_share = gets.strip

puts

print "Choose an access level (VIEWER, EDITOR, EDITOR_SHARE, ADMIN) for #{email_to_share}: "

level_to_share = gets.strip

puts "Sharing #{sheets[sheet_index_to_share]['name']} to #{email_to_share} as #{level_to_share}."

# prepare call parameters
options = {
  headers: { 'Content-Type' => 'application/json' },
  query: { sendEmail: true },
  body: {
    email: email_to_share,
    accessLevel: level_to_share
  }.to_json
}

body = ss_connection.request('post', "/sheet/#{sheets[sheet_index_to_share]['id']}/shares", options) 
puts "Sheet shared successfully, share ID: #{body['result']['id']}."
puts
puts "ENDING HelloSmartsheet..."