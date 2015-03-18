require_relative '../attribute'

module CollectionJSON
  class PageInfo < Attribute
    attribute :current_page
    attribute :total_items
    attribute :total_records
    attribute :page_size
  end
end