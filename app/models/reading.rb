class Reading < ApplicationRecord
belongs_to :user

validates :reading_type, presence: true
validates :content, presence: true
validates :date, presence: true
validates :category_Tarot, presence: true, inclusion: {in:['love','money','health']}

end
