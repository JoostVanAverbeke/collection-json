require_relative '../attribute'

module CollectionJSON
  class PageInfo < Attribute
    attribute :current_page
    attribute :total_items
    attribute :page_size
  end
end