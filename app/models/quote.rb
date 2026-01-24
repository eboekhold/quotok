class Quote < ApplicationRecord
  has_neighbors :embedding
end
