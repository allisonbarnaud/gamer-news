     
require 'sinatra'
require 'sinatra/reloader' if development?

get '/' do
  erb :index
end

db = PG.connect(ENV['DATABASE_URL'] || {dbname: 'enter database name here'})
result = db.exec(sql)
db.close



