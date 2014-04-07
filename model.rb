require 'data_mapper'
require 'dm-sqlite-adapter'
     
   class Url
      include DataMapper::Resource
     
      property :id, Serial
      property :url, Text, :required=>true
      property :code, Integer
      property :redirect, Text
      property :depth, Integer
      property :forms, String, :length => 256
      property :created_at, DateTime, :default=>DateTime.now
      property :updated_at, DateTime, :default=>DateTime.now
     
   end


