require 'bundler'
Bundler.require

require_all './lib'

DB = {
  :conn => SQLite3::Database.new("db/post.sqlite")
}