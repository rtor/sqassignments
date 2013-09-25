$KCODE = 'u'
require 'jcode'

require 'thread'
require 'rubygems'
require 'sinatra'
require 'system_timer'
require 'benchmark'
require 'active_record'
require './models/sqassignments.rb'

class App < Sinatra::Application

  get '/sqassignments' do   
    code = "<%= Time.now %>"
    erb code
  end

end

