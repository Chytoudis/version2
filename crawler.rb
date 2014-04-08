  #!/usr/bin/env ruby

    #gems required 
    require 'anemone'
    require 'nokogiri'
    require 'net/http'
    require 'data_mapper'
    require 'dm-sqlite-adapter'
    

    #entiry created by dataMapper 
    class Url
      include DataMapper::Resource
     
      property :id,          Serial
      property :url,         Text,       :required=>true
      property :code,        Integer
      property :redirect,    Text
      property :depth,       Integer
      property :forms,       Text
      property :href,        Text
      property :keywords,    Text
      property :keywords_count, Integer
      property :description, Text
      property :created_at,  DateTime,   :default=>DateTime.now
      property :updated_at,  DateTime,   :default=>DateTime.now
     
    end
     
     
    # Handles requests over HTTP
    def read_http(url)
     uri = URI(url)
     Net::HTTP.get_response(uri)
    end
     
    # Handles requests over HTTPS and SSL
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
     
    # Checks if there are keywords, numerates them and shows them in a list 
    def show_keywords (keywords)
      unless keywords.nil?
        puts "Your Keywords are:"
        keywords.split(',').each do |i|
          puts "keyword: #{i}"
        end
      end
    end
    
    # Checks if there is Description meta data in Header
    def show_description (description)
      unless description.nil?
        puts "Your description is:"
        description.split("\s").each do |i|
          puts "description: #{i}"
        end
      end
    end

    # Checks if keywords exist in the url of the site   
    def url_contains_keywords (url, keywords)
      unless keywords.nil?
        arr = keywords.split(',')
        arr.each do |keyword|
          if url.downcase.include? keyword.downcase
            puts "Found matching keyword: #{keyword}"
            return true
          end
        end
       
        puts "Didn't find any keywords in #{url}."
        false
      end
    end
   
    # Checks if keywords exist in Description
    def description_contains_keywords (description, keywords)
      unless keywords.nil?
        arr = keywords.split("\s")
        arr.each do |keyword|
          if description.downcase.include? keyword.downcase
            puts "Found matching keyword: #{keyword}"
            return true
          end
        end
       
        puts "Didn't find any keywords in #{description}."
        false
      end
    end

    #takes site name as an argument 
    raise "missing url" unless ARGV.count == 1
     
    site = ARGV[0]
    site = 'http://' + ARGV[0] unless ARGV[0].start_with?('http://') || ARGV[0].start_with?('https://')
    db_name = "noname.db"
    db_name = site.gsub("http://", "") if site.start_with?('http://')
    db_name = site.gsub("https://", "") if site.start_with?('https://')
    db_name += ".db"
     
    DataMapper.setup(:default, "sqlite3://#{File.join(Dir.pwd, db_name)}")
    DataMapper.finalize.auto_upgrade!
    
    #for all urls found  
    puts "Already found URLs for #{site}"
    Url.all.each do |url|
      puts "#{url}"
    end
     
     
    puts "Crawling #{site} - saving data on #{db_name}"
    saved=0
    Anemone.crawl("#{site}", :discard_page_bodies => true, depth_limit: 2) do |anemone|
      anemone.on_every_page do |page|
     
        res = read_http(page.url)   if page.url.instance_of?(URI::HTTP)
        res = read_https(page.url)  if page.url.instance_of?(URI::HTTPS)
     
        puts "#{page.url} is a redirect to #{res['location']}" if res.code.to_i == 301
     
        if res.code.to_i == 200
          doc = Nokogiri::HTML(res.body)
          puts "#{page.url} (depth: #{page.depth}, forms:#{doc.search("//form").count}) "
        end
       
        puts "#{page.url} was not found"                if res.code.to_i == 404
        puts "#{page.url} requires authorization"       if res.code.to_i == 401
        puts "#{page.url} returns an application error" if res.code.to_i == 500
       
        if ! Url.first(:url=>page.url)
          u = Url.new
          u.url = page.url
          u.depth = page.depth
          u.forms = doc.css("form").map { |a| (a['name'].nil?)? "nonamed":a['name'] }.compact.to_s.gsub("\n", ",") unless doc.nil?
          u.href = doc.css('div a').map { |link| (link['href'].nil?)? "":link['href'] }.compact.to_s.gsub("\n", ",") unless doc.nil?
          u.keywords = doc.xpath('//meta[@name="keywords"]/@content').map(&:value).compact.to_s.gsub("\n", ",") unless doc.nil?
          u.description = doc.xpath('//meta[@name="description"]/@content').map(&:value).compact.to_s.gsub("\n", ",") unless doc.nil?
          u.code = res.code.to_i
          u.redirect = res['location'] if res.code.to_i == 301
          u.keywords_count = u.keywords.split(',').count unless u.keywords.nil?
          ret = u.save
          saved += 1 if ret
         
          if ! ret
            puts "#{page.url} not saved"
            u.errors.each do |e|
              puts " * #{e}"
            end
          end
         
          show_keywords(u.keywords)
          url_contains_keywords(u.url, u.keywords)
          show_description(u.description)
          description_contains_keywords(u.description, u.keywords)
        end
      end
    end
     
    puts "#{saved} new urls saved on #{db_name}"

