Spree::Property.class_eval do
  scope :filterable, -> { where(filterable: true) }

  def filter_name
    "property_#{name.downcase}"
  end
end
