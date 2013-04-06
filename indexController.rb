require "sinatra"
require "fileutils"
require_relative "model.rb"

configure :development do
	MongoMapper.database = 'portiShop'
	set :show_exceptions, true
end

configure :production do
	MongoMapper.connection = Mongo::Connection.new('localhost', 20799)
	MongoMapper.database = 'portiShop'
	pass = ENV['mongoPassPortiDB']
	MongoMapper.database.authenticate("porti", pass)
end

get "/" do
	@shirts = Shirt.all()
	erb :index
end

get "/add" do
	erb :add
end

post "/add" do
	if ENV['mongoPassPortiDB'] != nil && ENV['mongoPassPortiDB'] != params[:key]
		throw(:halt, [401, "Not authorized\n"])
	end
	begin
		tempfile = params[:file][:tempfile] 
		filename = rand(36**8).to_s(36) + params[:file][:filename] 
		FileUtils.cp(tempfile.path, File.expand_path(filename, File.dirname(__FILE__) + "/public/uploads/"))
	rescue Exception => e
		if params[:file] == nil
			@meldung = "File: No file Selected"
		else
			@meldung = "File: Failed " + e.to_s
		end
	end
	
	if e == nil
		shirt = Shirt.new(:name => params[:name], :preis => params[:preis], :filename => "/uploads/" + filename)

		if shirt.save
		  @meldung = "successfully saved"
		else
		  @meldung = "Error(s): " + shirt.errors.map {|k,v| "#{k}: #{v}"}.to_s
		end
	end
	erb :add
end
