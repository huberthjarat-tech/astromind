class Profile < ApplicationRecord
  belongs_to :user

validates :birth_date, presence: true
validates :birth_city, presence: true
validates :birth_country, presence: true

end
