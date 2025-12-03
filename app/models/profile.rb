class Profile < ApplicationRecord
belongs_to :user

validates :birth_datetime, presence: true
validates :birth_city, presence: true
validates :birth_country, presence: true

end
