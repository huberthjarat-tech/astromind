class Reading < ApplicationRecord
belongs_to :user

validates :reading_type, presence: true
validates :content, presence: true
validates :date, presence: true


validates :category_tarot,
            presence: true,
            if: -> { reading_type == "tarot" }

validates :category_tarot,
            inclusion: { in: ["love", "money", "health"]},
            allow_blank: true

end
