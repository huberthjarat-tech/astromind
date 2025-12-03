# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# Creates a user

# HERE we word with the name of the models - mayusc and singular
#Create User


puts "Cleaning database..."
Reading.destroy_all
Profile.destroy_all
User.destroy_all

puts "Creating demo users"
user1 = User.create!(email: "hola@gmail.com", password: "123456", first_name: "huberth", last_name: "jara")
user2 = User.create!(email: "hola2@gmail.com", password: "123456", first_name: "jose", last_name: "jara")


puts "Creating profiles"
profile1 = Profile.create!(
  user: user1,
  birth_datetime: DateTime.new(1990, 5, 12, 13, 30),
  birth_city: "Berlin",
  birth_country: "Germany",
  natal_chart_text: "You have the best natal chart."
)


puts "Creating readings"

Reading.create!(
  user: user1,
  reading_type: "tarot",
  category_tarot: "money",
  date: Date.today,
  content: "your future with the money is incredible"
)

Reading.create!(
  user: user1,
  reading_type: "tarot",
  category_tarot: "health",
  date: Date.today,
  content: "you will live for ever"
)

Reading.create!(
  user: user1,
  reading_type: "tarot",
  category_tarot: "love",
  date: Date.today,
  content: "you will get married"
)

Reading.create!(
  user: user1,
  reading_type: "horoscope",
  category_tarot: nil,
  date: Date.today,
  content: "today your lucky number is 7"
)

puts "Finished!"
