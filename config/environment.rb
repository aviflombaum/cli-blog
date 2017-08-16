require 'bundler'
Bundler.require

DB = {
  :conn => SQLite3::Database.new("db/post.sqlite")
}

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => "db/post.sqlite"
)

require_all './lib'
