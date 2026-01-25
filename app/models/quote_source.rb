class QuoteSource < ApplicationRecord
  validates :remote_path, presence: true, uniqueness: true
  validates :quote_field, presence: true
  validates :author_field, presence: true

  has_many :quotes
end
