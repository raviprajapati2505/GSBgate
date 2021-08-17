# Locations of Qatar
location = Location.find_or_initialize_by(country: "Qatar")
location.list = ["Abu Hamour", "Ain Khalid", "Al Asiri"]
location.save!  
