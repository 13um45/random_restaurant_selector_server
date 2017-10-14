require 'random_restaurant_selector'

module CoreLogic

  DOCS = {
    parameters_accepted: "The only parameters accepted are:\n",
    location: "location: (e.g. address, neighborhood, city, state or zip, optional country).\n",
    term: "term: (e.g. 'food', 'restaurants').\n",
    radius: "radius: Search radius in meters. The max value is 40000 meters (25 miles).\n",
    open_now: "open_now: true or false\n",
    price: "price: 1 = $, 2 = $$, 3 = $$$, 4 = $$$$. '1, 2, 3' will filter the results to show the ones that are $, $$, or $$$."
  }.freeze

  DEFAULT_PARAMS = {
    location: ENV['MY_LOCATION'],
    term: 'food',
    radius: 900,
    open_now: true,
    price: '1,2',
    limit: 50
  }.freeze

  def self.return_restaurant_or_error(params)
    search_params = parsed_search_params(params)
    error_message = create_error_message(search_params, DEFAULT_PARAMS)
    return { text: error_message }.to_json unless error_message.nil?

    search = RandomRestaurantSelector::Search.new(DEFAULT_PARAMS.merge(search_params))
    restaurant = search.gimme_a_restaurant(search.get_businesses)
    restaurant.send_to_slack
  end

  def self.parsed_search_params(params)
    trimmed_text = params['text'].gsub('--res_chooser', '').gsub(' ', '')
    string_hash = Hash[trimmed_text.split(',').map { |str| str.split(':') }]
    sym_hash = Hash[string_hash.map { |(k, v)| [k.to_sym, v] }]
    sym_hash[:radius] = parse_radius(sym_hash[:radius])
    sym_hash[:open_now] = open_now?(sym_hash[:open_now])
    sym_hash.delete_if { |k, v| v.nil? }
  end

  def self.parse_radius(radius)
    return nil if radius.nil?
    if radius.to_i < 40000
      radius.to_i
    else
      40000
    end
  end

  def self.open_now?(open_now)
    return nil if open_now.nil?
    open_now.downcase == 'true'
  end

  def self.create_error_message(search_params, default_params)
    return nil if search_params.empty?
    error_message = ''
    search_params.each do |k, v|
      if default_params[k].nil?
        error_message << "Sorry did not recognize #{k}\n"
      end
    end
    return nil if error_message.empty?
    error_message << DOCS[:parameters_accepted] +
      DOCS[:location] +
      DOCS[:term] +
      DOCS[:radius] +
      DOCS[:open_now] +
      DOCS[:price]
  end
end
