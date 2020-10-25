def run_sql(sql, params = [])
    db = PG.connect(ENV['DATABASE_URL'] || {dbname: 'gamernews'})
    
    results = db.exec_params(sql, params)
    db.close
    
    return results
end

# def run_sql()
#     db = PG.connect(ENV['DATABASE_URL'] || {dbname: 'enter database name here'})
#     result = db.exec(sql)
#     db.close
# end

def find_user_by_email(email)
    results = run_sql("select * from users where email = '#{email}';")
    return results[0]
end

def find_user_by_id(id)
    results = run_sql("select * from users where id = $1;", [id])
    return results[0]
end

# inserting new user

# email = "allisonarnaud@gmail.com"
# password_digest = BCrypt::Password.create('password2')

# sql = "INSERT INTO users (email, password_digest) VALUES ('#{email}', '#{password_digest}');"

# run_sql(sql)