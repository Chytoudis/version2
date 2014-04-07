require 'data_mapper'
require 'dm-sqlite-adapter'
     
DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, "sqlite://#{Dir.pwd}/db.sqlite")
     
class Url
  include DataMapper::Resource
     
  property :id, Serial
  property :link_url, Text, :required=>true
  property :href, Text
  property :forms, Text
  property :title, Text
  property :code, Integer
  property :redirect, Text
  property :depth, Integer  
  property :created_at, DateTime, :default=>DateTime.now
  property :updated_at, DateTime, :default=>DateTime.now

 # has 1, :record, 'Record' #All Url will have a record
 # belongs_to :crawler, 'Crawler', key: true  #foreign key sto Crawler 	      
end



DataMapper.finalize.auto_upgrade!


