# City
location = Location.find_or_initialize_by(country: "Qatar")
location.list = ["Al Daayen", "Al Khor & Dhekra", "Al Shamal", "Al Sheehaniya", "Al Rayyan", "Al Wakrah", "Doha", "Umm Slal"]
location.save!

location = Location.find_or_initialize_by(country: "Bahrain")
location.list = ["Al Ḩadd", "Al Muharraq", "Ar Rifā‘", "Dār Kulayb", "Jidd Ḩafş", "Madīnat ‘Īsá", "Madīnat Ḩamad", "Manama", "Sitrah"]
location.save!

location = Location.find_or_initialize_by(country: "Kuwait")
location.list = ["Al Ahmadi", "Al Faḩāḩīl", "Al Farwānīyah", "Al Finţās", "Al Jahra", "Al Mahbūlah", "Al Manqaf", "Ar Riqqa", "Ḩawallī", "Janūb as Surrah", "Kuwait City", "Şabāḩ as Sālim"]
location.save!

location = Location.find_or_initialize_by(country: "Oman")
location.list = ["As Suwayq", "Bawshar", "Buraimi", "Ibri", "Nizwá", "Rustaq", "Saham", "Salalah", "Seeb", "Sohar", "Sur"]
location.save!

location = Location.find_or_initialize_by(country: "Saudi Arabia")
location.list = ["Al Hufūf", "Al Kharj", "Buraidah", "Dammam", "Jeddah", "Khamis Mushait", "Makkah", "Medina", "Riyadh", "Sulţānah", "Tabuk", "Ta'if"]
location.save!

location = Location.find_or_initialize_by(country: "United Arab Emirates")
location.list = ["Abu Dhabi", "Ajman", "Dubai", "Fujairah", "Ra’s al-Khaimah", "Sharjah", "Umm al-Qaiwain"]
location.save!

# Districts
district = District.find_or_initialize_by(country: "Qatar", city: "all")
district.list = ["Abu Hamour", "Ain Khalid", "Al Asiri", "Al Bidda", "Al Corniche", "Al Daayen", "Al Dafna", "Al Doha Al Jadeda", "Al Duhail", "Al Faroush", "Al Gharrafa", "Al Ghashmaia", "Al Ghouwariya", "Al Hilal", "Al Jumailiya", "Al Kabaan", "Al Karaana", "Al Khor", "Al Khoraitiyat", "Al Khulaifat", "AL Mamoura", "Al Manaseer", "Al Mashaf", "Al Messila", "Al Qassar", "Al Rayyan", "Al Sadd", "Al Shahaniya", "Al Shamal", "Al Soudan", "Al Thakhira", "Al Thumama", "Al Waab", "Al Wajba", "Al Wakrah", "Al Wukair", "Bin Mahmoud", "Bu Garn", "Doha Port", "Education City", "Hamad International Airport", "Hazm Al Markiya", "Industrial Area", "Katara", "Leabaib", "Learaig", "Lusail", "Lusail- Al Erkyah", "Lusail- Al Kharaej", "Lusail- Boulevard_COM", "Lusail- Boulivard_COM", "Lusail- ECQ_1", "Lusail- Entertainment City", "Lusail- Entertainment Island", "Lusail- Fox Hills", "Lusail- Marina", "Lusail- North-_RES", "Lusail- Qetaifan", "Lusail- Qetaifan Islands", "Lusail- Stadium District", "Lusail- Waterfront_COM/SEEF", "Lusail- Waterfront_RES", "Madinat Khalifa", "Mebaireek", "Mesaieed", "Mesaimeer", "Msheireb", "Muaither", "Muraikh", "West Bay", "Nuaija", "Old Airport", "Onaizah", "Ras Bu Aboud", "Ras Bu Fontas", "Ras Laffan", "Rawdat Abal Heeran", "Rawdat Al Faras", "Rawdat Al Khail", "Rawdat Rashid", "Um Al Houl", "Umm Al Saneem", "Umm Ghuwailina", "Umm Salal", "Umm Salal Ali", "Wadi Al Banat", "Wadi Al Sail"]
district.save!

# Change name for already present projects
Project.where("country ILIKE :name", name: "%Qatar%").each do |project|
  project.country = "Qatar"
  project.save(validate: false)
end

Project.where("country ILIKE :name", name: "%Oman%").each do |project|
  project.country = "Oman"
  project.save(validate: false)
end

Project.where("country ILIKE :name", name: "%Kuwait%").each do |project|
  project.country = "Kuwait"
  project.save(validate: false)
end

puts "Locations are added successfully.........."
