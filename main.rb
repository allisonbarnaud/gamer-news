require 'sinatra'
require 'sinatra/reloader' if development?
require 'pg'
require 'httparty'
require 'bcrypt'

require_relative 'data_access'

enable :sessions

def logged_in?()
  if session[:user_id]
    true
  else
    false
  end
end

def current_user()
  find_user_by_id(session[:user_id])
end

get '/' do
  if session["user_id"] != nil

    sql = "SELECT * FROM preferences WHERE user_id = $1;"

    preferences = run_sql(sql, [session[:user_id]])[0]

    if preferences["filter_term"] == ''
      search_term = 'games'
    else
      search_term = preferences["filter_term"] #use '%' as a space for multiple words
    end
    domains = 'ign.com,polygon.com,gamespot.com'
    
    results_number = preferences["results_number"]
    sort = 'popularity'
    news_api_key = '6400348d62a040ba8d3bf438f6c7f1e6'

    url1 = "https://newsapi.org/v2/everything?q=#{search_term}&domains=#{domains}&pageSize=#{(results_number.to_i)+6}&sortBy=#{sort}&apiKey=#{news_api_key}"
    url2 = "https://newsapi.org/v2/everything?q=#{search_term}&domains=#{domains}&pageSize=6&sortBy=#{sort}&apiKey=#{news_api_key}"
  else
    search_term = 'games' #use '%' as a space for multiple words
    domains = 'ign.com,polygon.com,gamespot.com'
    sort = 'popularity'
    news_api_key = '6400348d62a040ba8d3bf438f6c7f1e6'

    url1 = "https://newsapi.org/v2/everything?q=#{search_term}&domains=#{domains}&pageSize=26&sortBy=#{sort}&apiKey=#{news_api_key}"
    url2 = "https://newsapi.org/v2/everything?q=#{search_term}&domains=#{domains}&pageSize=6&sortBy=#{sort}&apiKey=#{news_api_key}"
  end
  data = HTTParty.get(url1)
  headlines = HTTParty.get(url2)

  erb :index, locals: {
    data: data,
    headlines: headlines
  }
end

get '/search/:console' do

  search_term = params["console"] #use '%' as a space for multiple words
  domains = 'ign.com,polygon.com,gamespot.com'
  sort = 'relevancy'
  news_api_key = '6400348d62a040ba8d3bf438f6c7f1e6'

  url = "https://newsapi.org/v2/everything?qInTitle=#{search_term}&domains=#{domains}&sortBy=#{sort}&language=en&apiKey=#{news_api_key}"
  
  data = HTTParty.get(url)

  erb :search_result, locals: {
    data: data
    
  }
end

get '/login' do
  erb :login
end

post '/login' do
  user = find_user_by_email(params["email"])

  if BCrypt::Password.new(user['password_digest']).==(params['password'])

    session[:user_id] = user['id']
    redirect "/"
  else
    erb :login
  end
end

delete '/logout' do
  session[:user_id] = nil
  redirect '/'
end

get '/signup' do
  erb :signup
end

post '/signup' do
  if params["password"]==params["password-check"]
    email = params["email"]
    password_digest = BCrypt::Password.create(params["password"])
    username = params["username"]
    sql = "INSERT INTO users (email, username, password_digest) VALUES ($1, $2, $3);"
    run_sql(sql, [email, username, password_digest])
    sql2 = "SELECT id FROM users where email = $1;"
    user_id = run_sql(sql2, [email])[0]["id"]
    sql3 = "INSERT INTO preferences (user_id) VALUES ($1);"
    run_sql(sql3, [user_id])

    redirect '/login'
  else
    redirect '/signup'
  end
end

get '/my_page/:id/edit' do

  sql = "SELECT * FROM users WHERE id = #{params["id"]};"
  sql2 = "SELECT * FROM preferences WHERE user_id = #{params["id"]}"

  user_info = run_sql(sql)[0]
  user_preferences = run_sql(sql2)[0]

  erb :edit, locals: {user_info: user_info, user_preferences: user_preferences}
end

get '/my_page/:id' do
  sql = "SELECT * FROM users WHERE id = $1;"
  sql2 = "SELECT * FROM preferences WHERE user_id = $1;"

  user_info = run_sql(sql, [params["id"]])[0]
  user_preferences = run_sql(sql2, [params["id"]])[0]

  erb :my_page, locals: {user_info: user_info, user_preferences: user_preferences}
end



patch '/my_page/:id' do
  sql = "UPDATE users SET username = $1, email = $2 WHERE id = $3;"
  sql2 = "UPDATE preferences SET filter_term = $1, results_number = $2 WHERE user_id = $3;"

  run_sql(sql, [params["username"], params["email"], params["id"]])
  run_sql(sql2, [params["filter_term"], params["results_number"], params["id"]])

  redirect "/my_page/#{params["id"]}"
end

get '/search' do

  search_term = params["searchbox"] #use '%' as a space for multiple words
  domains = 'ign.com,polygon.com,gamespot.com'
  sort = 'relevancy'
  news_api_key = '6400348d62a040ba8d3bf438f6c7f1e6'

  url = "https://newsapi.org/v2/everything?qInTitle=#{search_term}&domains=#{domains}&sortBy=#{sort}&language=en&apiKey=#{news_api_key}"

  data = HTTParty.get(url)

  erb :search_result, locals: {data: data}
end

delete '/my_page/:id' do
  
  sql = "delete from users where id = $1;"

  run_sql(sql, [params["id"]])
  session[:user_id] = nil
  redirect "/"
end




