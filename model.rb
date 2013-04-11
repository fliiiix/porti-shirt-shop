require "mongo_mapper"
class Shirt
	include MongoMapper::Document

	key :name,		String, :required => true, :length => 5..20
	key :preis,		Float, :required => true, :numeric => true
	key :filename,	String, :required => true
	key :status,	Float
end

