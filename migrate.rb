
$LOAD_PATH << File.expand_path(__dir__)

require 'active_record'
require 'db'

db_connection do
  require 'db/schema'
end
