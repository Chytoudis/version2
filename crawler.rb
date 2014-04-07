#!/usr/bin/env ruby
require 'anemone'
require 'nokogiri'
require 'net/http'
require './test_model'
     
def read_http(url)
    uri = URI(url)
    Net::HTTP.get_response(uri)
end
     
def read_https(url)
    response = nil
    uri = URI(url)
     
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.start do |http|
    response = Net::HTTP.get_response(uri)
end
    response
end
     
raise "missing url" unless ARGV.count == 1
     
    site = ARGV[0]
    site = 'http://' + ARGV[0] unless ARGV[0].start_with?('http://') || ARGV[0].start_with?('https://')
    db_name = "noname.db"
    db_name = site.gsub("http://", "") if site.start_with?('http://')
    db_name = site.gsub("https://", "") if site.start_with?('https://')
    db_name += ".db"
     
    DataMapper.setup(:default, "sqlite3://#{File.join(Dir.pwd, db_name)}")
    DataMapper.finalize
    DataMapper.auto_upgrade!
     
    puts "Already found URLs for #{site}"
    Url.all.each do |url|
    puts "#{url}"
    
end
   
   puts "Crawling #{site} - saving data on #{db_name}"
  saved=0
  Anemone.crawl("#{site}", :discard_page_bodies => true, :depth_limit=>3) do |anemone|
  anemone.on_every_page do |page|
     
  res = read_http(page.url) if page.url.instance_of?(URI::HTTP)
  res = read_https(page.url) if page.url.instance_of?(URI::HTTPS)
	     
  puts "#{page.url} is a redirect to #{res['location']}" if res.code.to_i == 301
     
    if res.code.to_i == 200
        doc = Nokogiri::HTML(res.body)
        puts "#{page.url} (depth: #{page.depth}, forms:#{doc.search("//form").count}, title:#{doc.search("//title").count}, href:#{doc.search("//href").count} )"
    end
        puts "#{page.url} was not found" if res.code.to_i == 404
        puts "#{page.url} requires authorization" if res.code.to_i == 401
        puts "#{page.url} returns an application error" if res.code.to_i == 500
    
	#edo thelei alagi sto na diavazei o crawler to css	
u = Url.first(link_url: page.url)
  if !u
    u = Url.new
    u.link_url = page.url
    u.depth = page.depth      
    u.redirect = res['location'] if res.code.to_i == 301
    u.code = res.code.to_i
    u.forms = doc.css("form").map{ |a| (a['name'].nil?)? "nonamed":a['name'] }.compact.to_s.gsub("\n", ",") unless doc.nil?
    u.title = doc.css("title").map{ |a| (a['name'].nil?)? "nonamed":a['name'] }.compact.to_s.gsub("\n", ",") unless doc.nil?
    u.href = doc.css("href").map{ |a| (a['name'].nil?)? "nonamed":a['name'] }.compact.to_s.gsub("\n", ",") unless doc.nil?
     
    ret = u.save
    saved += 1 if ret
  if ! ret
    puts "#{page.url} not saved"
    u.errors.each do |e|
    puts " * #{e}"
  end
  end
       
end
end
     
   puts "#{saved} new urls saved on #{db_name}"

end
