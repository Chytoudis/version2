u = Url.first(url: page.url)
  if !u
    u = Url.new
    u.url = page.url
    u.depth = page.depth      
    u.redirect = res['location'] if res.code.to_i == 301
    u.code = res.code.to_i
     
    ret = u.save
    saved += 1 if ret
  if ! ret
    puts "#{page.url} not saved"
    u.errors.each do |e|
    puts " * #{e}"
  end
  end
     
     
....
     
----- irb
     

y = Crawler.new
  y.forms = doc.css("form").map{ |a| (a['name'].nil?)? "nonamed":a['name'] }.compact.to_s.gsub("\n", ",") unless doc.nil?
  y.title = doc.css("title").map{ |a| (a['name'].nil?)? "nonamed":a['name'] }.compact.to_s.gsub("\n", ",") unless doc.nil?
  y.href = doc.css("href").map{ |a| (a['name'].nil?)? "nonamed":a['name'] }.compact.to_s.gsub("\n", ",") unless doc.nil?
  y.url = u

    ret = y.save
    saved += 1 if ret

    if ! ret         
      puts "#{page.url} was not parsed"
      y.errors.each do |e|
      puts " * #{e}"
    end


    y = Crawler.new
  y.forms = doc.css("form").map{ |a| (a['name'].nil?)? "nonamed":a['name'] }.compact.to_s.gsub("\n", ",") unless doc.nil?
  y.title = doc.css("title").map{ |a| (a['name'].nil?)? "nonamed":a['name'] }.compact.to_s.gsub("\n", ",") unless doc.nil?
  y.href = doc.css("href").map{ |a| (a['name'].nil?)? "nonamed":a['name'] }.compact.to_s.gsub("\n", ",") unless doc.nil?
  y.crawler_url = u.link_url
# reg expression for href (?i)<a([^>]+)>
  ret = y.save
    saved += 1 if ret
      if ! ret
         
        puts "#{page.url} was not parsed"
        y.errors.each do |e|
        puts " * #{e}"
      end
     
end

class Record
  include DataMapper::Resource 

  property :id, Serial, :required=>true
  property :record_url, Text
  property :parsed, Boolean, :default => false
  property :created_at, DateTime
  property :updated_at, DateTime

  belongs_to :url, 'Url', key= true #foreign key to url
end   

class Crawler
  include DataMapper::Resource
  
  property :id, Serial
  property :crawler_url, Text, :required=>true
  property :href, Text
  property :forms, Text
  property :title, Text
  
  has 1, :url , 'Url' # 1 to 1 relationship

end
