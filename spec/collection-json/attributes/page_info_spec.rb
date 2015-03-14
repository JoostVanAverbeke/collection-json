require 'spec_helper'
require 'collection-json/attributes/page_info'

describe CollectionJSON::PageInfo do

  let(:page_info) { CollectionJSON::PageInfo.from_hash({
                             current_page: 1,
                             total_items: 10,
                             page_size: 2
                     })
  }

  it 'be serializable' do
    expect(page_info.to_json.class).to eq(String)
  end
  it 'has an attribute current_page' do
    expect(page_info.current_page).to eq(1)
  end

  it 'has an attribute total_items' do
    expect(page_info.total_items).to eq(10)
  end

  it 'has an attribute page_size' do
    expect(page_info.page_size).to eq(2)
  end

end