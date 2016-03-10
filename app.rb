require "sinatra/base"
require "tilt/erb"
require "sinatra/activerecord"
require "slim"
require_relative "./models/user"
require_relative "./models/image"

class ELSWC < Sinatra::Application
  enable :sessions

  register Sinatra::ActiveRecordExtension
  set :database_file, "config/database.yml"


  helpers do
    def current_user
      if session[:user_id]
        @current_user ||= User.find_by(id: session[:user_id])
      end
    end
  end

  get "/login" do
    @user = User.new
    @title = "Please enter your login details"
    slim :login
  end
  
  post "/login" do
    user = User.find_by(email: params[:email].downcase)
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect to("/")
    else
      @title = "Please enter your login details"
      slim :login
    end
  end

  get "/logout" do
    session[:user_id] = nil
    redirect to("/")
  end

  get "/" do
    @title = "Welcome to ELSWC"
    slim :index
  end

  get "/about" do
    @title = "About ELSWC"
    slim :about
  end

  get "/profile/:name" do
    @name = params[:name].capitalize
    slim :profile
  end

  get '/users' do
    @users = User.all
    @title = "Welcome to ELSWC"
    slim :"user/index"
  end

  get "/signup" do
    @title = "Sign up"
    @user = User.new
    slim :hello_form
  end

  post "/signup" do
    @user = User.new(
      username:              params[:username],
      display_name:          params[:display_name],
      email:                 params[:email],
      email_confirmation:    params[:email_confirmation],
      password:              params[:password],
      password_confirmation: params[:password_confirmation],
    )
    if @user.save
      @title = "Welcome!"
      slim :form
    else
      @title = "Sign up"
      slim :hello_form
    end
  end

  get '/users/:username' do
    @title = "Welcome to ELSWC"
    @user  = User.find_by(username: params[:username])
    if @user
      slim :"user/show"
    else
      status 404
      slim :not_found
    end
  end
  
  get '/images' do
    @images = Image.all
    @title = "Welcome to ELSWC"
    slim :"image/index"
  end
  
end
