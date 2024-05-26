class Favorite < ApplicationRecord

belongs_to :user
belongs_to :book
has_many :notifications, dependent: :destroy

validates :user_id, uniqueness: {scope: :book_id}
end
