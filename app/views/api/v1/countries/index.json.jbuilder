json.countries(CS.countries.sort_by{|_key, value| value }) do |country|
  json.countrycode country[0]
  json.countryname country[1]
end