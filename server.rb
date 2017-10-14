require 'sinatra'
require_relative 'core_logic'

post '/' do
  CoreLogic.return_restaurant_or_error(params)
end
