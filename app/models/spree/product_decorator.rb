Spree::Product.class_eval do
  searchkick searchable: [:name], word_start: [:name], callbacks: :async, settings: { "index.mapping.total_fields.limit": 5000 }

  def search_data
    json = {
      id: id,
      name: name,
      description: description,
      active: available?,
      created_at: created_at,
      updated_at: updated_at,
      price: price,
      currency: [currency, currency.downcase],
      conversions: orders.complete.count,
      taxon_ids: taxons.map(&:self_and_ancestors).flatten.uniq.map(&:id),
      taxon_names: taxons.map(&:self_and_ancestors).flatten.uniq.map(&:name)
    }

    Spree::Property.all.each do |prop|
      json.merge!(Hash[prop.filter_name, property(prop.name)])
    end

    Spree::Taxonomy.all.each do |taxonomy|
      json.merge!(Hash[taxonomy.filter_name, taxon_by_taxonomy(taxonomy.id).map(&:id)])
    end

    json
  end

  def taxon_by_taxonomy(taxonomy_id)
    taxons.joins(:taxonomy).where(spree_taxonomies: { id: taxonomy_id })
  end

  def self.autocomplete(keywords)
    if keywords
      Spree::Product.search(
        keywords,
        fields: [:name],
        match: :word_start,
        limit: 10,
        load: false,
        misspellings: {below: 3},
        where: search_where
      ).map(&:name).map(&:strip).uniq
    else
      Spree::Product.search(
        '*',
        fields: [:name],
        load: false,
        misspellings: {below: 3},
        where: search_where
      ).map(&:name).map(&:strip)
    end
  end

  def self.search_where
    {
      active: true,
      price: { not: nil }
    }
  end
 end
