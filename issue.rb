#!/usr/bin/env ruby
# encoding: utf-8
require 'rest_client'
require 'net/http'
require 'uri'
require 'open-uri'
require 'json'
require 'pp'
require 'csv'
require 'optparse'
@jira_url = "https://#{@name}.atlassian.net/rest/api/2/issue"

=begin
 sample.csv
    type, title, id, estimate, label
    story, ストーリー1
    sub, タイトル',10401,2h,スライドショー
    sub, タイトル',10401,2h,スライドショー
    sub, タイトル',10401,2h,スライドショー
    story, ストーリー2
    sub, タイトル,10401,2h,スライドショー
    sub, タイトル,10401,2h,スライドショー
    sub, タイトル,10401,2h,スライドショー
    
 ex:
    $ ruby issue.rb -u {user} -p {password} -c sample.csv -r test -f TST

=end

def cmdline
  args = {}
  OptionParser.new do |parser|
    parser.on('-u VALUE', '--user VALUE', 'user') {|v| args[:user] = v}
    parser.on('-p VALUE', '--password VALUE', 'password') {|v| args[:password] = v}
    parser.on('-c VALUE', '--csv VALUE', 'csv file') {|v| args[:csv] = v}
    parser.on('-r VALUE', '--project VALUE', 'project name') {|v| args[:project] = v}
    parser.on('-f VALUE', '--prefix VALUE', 'project prefix') {|v| args[:prefix] = v}
    parser.parse!(ARGV)
  end
  args
end

args = cmdline
@id = args[:user]
@pw = args[:password]
@csv = args[:csv]
@project = args[:prefix]
@name = args[:project]

#
# JSON作成
#
def makeJSON param
  json = {:fields => {}}
  json[:fields][:project] = {:key => @project}
  json[:fields][:description] = param[:description] unless param[:description].nil?
  json[:fields][:summary] = param[:summary] unless param[:summary].nil?
  json[:fields][:issuetype] = {:id => param[:issuetype].to_s} unless param[:issuetype].nil?
  json[:fields][:timetracking] = {:originalEstimate => param[:estimate].to_s} unless param[:estimate].nil?
  json[:fields][:parent] = {:key => param[:parent].to_s} unless param[:parent].nil?
  json[:fields][:labels] = param[:labels] unless param[:labels].nil?
  return json.to_json
end

#
# タスク登録共通処理
#
def createIssue param
  body = makeJSON param
  puts body
  url = URI.parse @jira_url
  req = Net::HTTP::Post.new url.path, {'Content-Type' =>'application/json'}
  req.basic_auth @id, @pw
  req.body = body
  req["Content-Type"] = "application/json"

  res = Net::HTTP.new url.host, url.port
  #res.set_debug_output $stderr
  res.use_ssl = true
  res.verify_mode = OpenSSL::SSL::VERIFY_NONE

  res.start {|http|
    response = http.request req
    json = JSON.parse(response.body)
    return json["key"]
  }
end

#
# Storyチケットの作成
#
def createStory title
  param = {}
  param[:summary] = title
  param[:issuetype] = 10001
  key = createIssue param
  return key
end

#
# サブタスクの作成
#
def createSubTask param
  param[:description] = "h3. 作業内容 \r\n\r\nh3. 終了条件 \r\n\r\n"
  return createIssue param
end

@currentStory = ""
#
# メイン処理
#
def main
  csv = CSV.read(@csv, headers:true)
  csv.each do |line|
    next if !line[0].nil? && line[0][0,1] == "#"
    if line[0] == "story" then
      @currentStory = createStory(line[1])
    else
      createSubTask({
        :summary => line[1],
        :issuetype => line[2],
        :estimate => line[3],
        :parent => @currentStory
      });
    end
  end
end

main

# 10001 : ストーリ
# 10201	サブタスク
# 10401	サブ実装
