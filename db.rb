
def db_connection
  ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: 'db.sqlite3')

  yield if block_given?

  ActiveRecord::Base.connection.disconnect!
end

