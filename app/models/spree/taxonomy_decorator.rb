Spree::Taxonomy.class_eval do
  scope :filterable, -> { where(filterable: true) }

  def filter_name
    "taxonomy_#{name.downcase}_ids"
  end
end
