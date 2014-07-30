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
      # users = @database_connection.sql("SELECT * FROM users WHERE id != #{user["id"]}")
      # fish = @database_connection.sql("SELECT * FROM fish WHERE user_id = #{current_user["id"]}")
      users = User.where.not(id:current_user["id"])
      fish = Fish.where(user_id:current_user["id"])
      erb :signed_in, locals: {current_user: user, users: users, fish_list: fish}
    else
      erb :signed_out
    end
  end

  get "/register" do
    erb :register
  end

  post "/registrations" do
    if validate_registration_params

      User.create(:username => "#{params[:username]}", :password => "#{params[:password]}")

      flash[:notice] = "Thanks for registering"
      redirect "/"
    else
      erb :register
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

    # delete_sql = <<-SQL
    # DELETE FROM users
    # WHERE id = #{params[:id]}
    # SQL
    #
    # @database_connection.sql(delete_sql)

    redirect "/"
  end

  get "/fish/new" do
    erb :"fish/new"
  end

  get "/fish/:id" do
    # fish = @database_connection.sql("SELECT * FROM fish WHERE id = #{params[:id]}").first
    fish = Fish.find(id:params[:id])
    erb :"fish/show", locals: {fish: fish}
  end

  post "/fish" do
    if validate_fish_params
    Fish.create(:name => "#{params[:name]}", :wikipedia_page => "#{params[:wikipedia_page]}", :user_id => current_user["id"])

      # insert_sql = <<-SQL
      # INSERT INTO fish (name, wikipedia_page, user_id)
      # VALUES ('#{params[:name]}', '#{params[:wikipedia_page]}', #{current_user["id"]})
      # SQL
      #
      # @database_connection.sql(insert_sql)

      flash[:notice] = "Fish Created"

      redirect "/"
    else
      erb :"fish/new"
    end
  end

  private

  def validate_registration_params
    if params[:username] != "" && params[:password].length > 3 && username_available?(params[:username])
      return true
    end

    error_messages = []

    if params[:username] == ""
      error_messages.push("Username is required")
    end

    if User.find_by(:username => params[:username])
    # !username_available?(params[:username])
      error_messages.push("Username has already been taken")
    end

    if params[:password] == ""
      error_messages.push("Password is required")
    elsif params[:password].length < 4
      error_messages.push("Password must be at least 4 characters")
    end

    flash[:notice] = error_messages.join(", ")

    false
  end

  def validate_fish_params
    if params[:name] != "" && params[:wikipedia_page] != ""
      return true
    end

    error_messages = []

    if params[:name] == ""
      error_messages.push("Name is required")
    end

    if params[:wikipedia_page] == ""
      error_messages.push("Wikipedia page is required")
    end

    flash[:notice] = error_messages.join(", ")

    false
  end

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
    existing_users = User.where(username:username)

    # find(:first, :conditions => "user_name = '#{user_name}' AND password = '#{password}'")
      # @database_connection.sql("SELECT * FROM users where username = '#{username}'")

    existing_users.length == 0
  end

  def authenticate_user
   User.find_by(username:"#{params[:username]}", password:"#{params[:password]}")
    # select_sql = <<-SQL
    # SELECT * FROM users
    # WHERE username = '#{params[:username]}' AND password = '#{params[:password]}'
    # SQL
    #
    # @database_connection.sql(select_sql).first
  end

  def current_user
    if session[:user_id]
      User.find_by(id:session[:user_id])
      #
      # select_sql = <<-SQL
      # SELECT * FROM users
      # WHERE id = #{session[:user_id]}
      # SQL
      #
      # @database_connection.sql(select_sql).first
    else
      nil
    end
  end
end
