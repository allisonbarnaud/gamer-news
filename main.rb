     
require 'sinatra'
require 'sinatra/reloader' if development?
require 'pg'

get '/' do
  erb :index
end

def run_sql()
  db = PG.connect(ENV['DATABASE_URL'] || {dbname: 'enter database name here'})
  result = db.exec(sql)
  db.close
end



