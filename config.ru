require '/mnt/mysql/sqassignments/app'

use Rack::ShowExceptions

run App.new
