require "active_record"

class User < ActiveRecord::Base
  has_many :fish
  validates :username, :presence => { :message => "Username is required"}, :uniqueness => {:message => "Username has already been taken"}
  validates :password, :presence => { :message => "Password is required" }
  validates :password, :length => {:minimum => 4, :message => "Password must be at least 4 characters"}
end