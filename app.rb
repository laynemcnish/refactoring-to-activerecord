require "sinatra"
require "rack-flash"
require "./lib/connection"
require "./lib/fish"
require "./lib/user"

class App < Sinatra::Application
  enable :sessions
  use Rack::Flash

  def initialize
    super
  end

  get "/" do
    user = current_user
    if current_user
      users = User.where.not(id: current_user["id"])
      fish = Fish.where(user_id: current_user["id"])
      erb :signed_in, locals: {current_user: user, users: users, fish_list: fish}
    else
      erb :signed_out
    end
  end

  get "/register" do
    erb :register
  end

  post "/registrations" do
    user = User.create(:username => "#{params[:username]}", :password => "#{params[:password]}")
    if user.valid?
      user.save
      flash[:notice] = "Thanks for registering"
      redirect "/"
    else
      erb :register, locals: {}

    end
  end

  post "/sessions" do
    if validate_authentication_params
      user = authenticate_user
      if user != nil
        session[:user_id] = user["id"]
      else
        flash[:notice] = "Username/password is invalid"
      end
    end

    redirect "/"
  end

  delete "/sessions" do
    session[:user_id] = nil
    redirect "/"
  end

  delete "/users/:id" do
    User.destroy_all(:id => (params["id"].to_i))
    redirect "/"
  end

  get "/fish/new" do
    erb :"fish/new"
  end

  get "/fish/:id" do
    fish = Fish.find(id: params[:id])
    erb :"fish/show", locals: {fish: fish}
  end

  post "/fish" do
    fish = Fish.create(:name => "#{params[:name]}", :wikipedia_page => "#{params[:wikipedia_page]}", :user_id => current_user["id"])
    if fish.valid?
      fish.save
      flash[:notice] = "Fish Created"
      redirect "/"
    else
      erb :"fish/new"
    end
  end

  private

  def validate_authentication_params
    if params[:username] != "" && params[:password] != ""
      return true
    end
    error_messages = []
    if params[:username] == ""
      error_messages.push("Username is required")
    end
    if params[:password] == ""
      error_messages.push("Password is required")
    end
    flash[:notice] = error_messages.join(", ")
    false
  end

  def username_available?(username)
    existing_users = User.where(username: username)
    existing_users.length == 0
  end

  def authenticate_user
    User.find_by(username: "#{params[:username]}", password: "#{params[:password]}")
  end

  def current_user
    if session[:user_id]
      User.find_by(id: session[:user_id])
    else
      nil
    end
  end
end
