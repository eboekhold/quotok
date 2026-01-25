class Quote < ApplicationRecord
  belongs_to :quote_source

  validates :remote_id, presence: true
  validates_uniqueness_of :remote_id, scope: [ :quote_source ]

  has_neighbors :embedding

  def remote_uri
    "#{quote_source.remote_path}#{remote_id}"
  end
end
