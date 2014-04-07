require 'rubygems'
require 'nokogiri'
require 'open-uri'

url = "https://www.google.gr/?gfe_rd=cr&ei=leg_U4bKMabe8gehw4DQBg#q=anime"
doc = Nokogiri::HTML(open(url))
puts doc.at_css("title").text
doc.css(".item").each do |item|
  title = item.at_css(".prodLink").text
  price = item.at_css(".PriceCompare .BodyS, .PriceXLBold").text[/\$[0-9\.]+/]
  puts "#{title} - #{price}"
  puts item.at_css(".prodLink")[:href]
end
