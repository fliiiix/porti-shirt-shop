require "sinatra"
require "fileutils"
use Rack::Session::Pool, :expire_after => 2592000
require_relative "model.rb"

configure :development do
	MongoMapper.database = 'portiShop'
	enable :show_exceptions
	Debug = true
end

configure :production do
	MongoMapper.connection = Mongo::Connection.new('localhost', 20799)
	MongoMapper.database = 'portiShop'
	Pass = ENV['mongoPassPortiDB']
	MongoMapper.database.authenticate("porti", Pass)
	Debug = false
end

get "/" do
	@shirts = Shirt.where(:status => 1)
	erb :index
end

get "/about" do
	erb :about
end

post "/freischalten" do
	if (Pass != nil && Pass != params[:key])
		halt erb :login
	end
	if Pass == params[:key]
		session["login"] = true
	end
	redirect to('/freischalten')
end

get "/freischalten" do
	puts "session " + (session["login"] != true).to_s
	puts "Debug " + Debug.to_s
	puts "endstatus " + (session["login"] != true || Debug).to_s
	if session["login"] != true && !Debug
		halt erb :login
	end
	@shirts = Shirt.where(:status => nil)
	@login = true
	erb :index
end

get "/freischalten/:status/:id" do
	shirt = Shirt.find(params[:id])
	if shirt != nil
		if params[:status] == "true"
			shirt.status = 1
		end
		if params[:status] == "false"
			shirt.status = -1
		end
		shirt.save!
	end
	redirect to('/freischalten')
end

get "/add" do
	erb :add
end

post "/add" do
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
		shirt = Shirt.new(:name => params[:name], 
						  :preis => params[:preis], 
						  :filename => "/uploads/" + filename, 
						  :status => nil)

		if shirt.save
		  @meldung = "successfully saved"
		else
		  @meldung = "Error(s): " + shirt.errors.map {|k,v| "#{k}: #{v}"}.to_s
		end
	end
	erb :add
end
