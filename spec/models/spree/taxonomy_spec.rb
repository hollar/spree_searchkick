require 'spec_helper'

RSpec.describe Spree::Taxonomy, type: :model do
  describe '#filter_name' do
    let(:taxonomy) { create(:taxonomy, name: 'awesome_category') }

    it 'respond with taxonomy name downcased' do
      expect(taxonomy.filter_name).to eq('taxonomy_awesome_category_ids')
    end
  end
end
