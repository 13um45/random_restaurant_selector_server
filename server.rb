require 'sinatra'
require 'random_restaurant_selector'


get '/' do
puts request_hash = { location: ENV['MY_LOCATION'], term: 'food', radius: 900, open_now: false, price: '1,2', limit: 50 }
puts search = RandomRestaurantSelector::Search.new(request_hash)
puts restaurant = search.gimme_a_restaurant(search.get_businesses)
puts restaurant.send_to_slack
end