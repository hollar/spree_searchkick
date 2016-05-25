module Spree::Search
  class Searchkick < Spree::Core::Search::Base
    attr_writer :searchkick_options

    def initialize(params = {})
      @searchkick_options = {}
      @order_params = params[:order_params]
      super
    end

    def retrieve_products
      @products = get_base_elasticsearch
    end

    def get_base_elasticsearch
      curr_page = page || 1
      opts = @searchkick_options.deep_merge(where: where_query, aggs: aggregations, smart_aggs: true,
                                            order: sorted, page: curr_page, per_page: per_page)
      Spree::Product.search(keyword_query, opts)
    end

    def where_query
      where_query = {
        active: true,
        currency: current_currency,
        price: {not: nil}
      }
      where_query.merge!({taxon_ids: taxon.id}) if taxon
      add_search_filters(where_query)
    end

    def keyword_query
      (keywords.nil? || keywords.empty?) ? "*" : keywords
    end

    def sorted
      @order_params ||= {}
      @order_params[:conversions] = :desc if conversions
      @order_params
    end

    def aggregations
      fs = []
      Spree::Taxonomy.filterable.each do |taxonomy|
        fs << taxonomy.filter_name.to_sym
      end
      Spree::Property.filterable.each do |property|
        fs << property.filter_name.to_sym
      end
      fs
    end

    def add_search_filters(query)
      return query unless search
      search.each do |name, scope_attribute|
        query.merge!(Hash[name, scope_attribute])
      end
      query
    end

    def prepare(params)
      super
      @properties[:conversions] = params[:conversions]
    end
  end
end
