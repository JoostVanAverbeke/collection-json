require 'spec_helper'
require 'collection-json'

describe CollectionJSON do
  describe :generate_for do
    before :each do
      @friends = [
        {
          "id"        =>  "jdoe",
          "full-name" =>  "J. Doe",
          "email"     =>  "jdoe@example.org"
        },
        {
          "id"        =>  "msmith",
          "full-name" =>  "M. Smith",
          "email"     =>  "msmith@example.org"
        },
        {
          "id"        =>  "rwilliams",
          "full-name" =>  "R. Williams",
          "email"     =>  "rwilliams@example.org"
        }
      ]
    end

    it 'should generate an object with the attributes we expect' do
      response = CollectionJSON.generate_for('/friends/') do |builder|
        builder.set_version '1.1'
        builder.set_page_info(current_page: 1, total_items: 10, total_records: 1000, page_size: 2)
        builder.add_link '/friends/rss', 'feed'
        @friends.each do |friend|
          builder.add_item("/friends/#{friend['id']}") do |item|
            item.add_data "full-name", value: friend["full-name"]
            item.add_data "email", value: friend["email"]
            item.add_link "/blogs/#{friend['id']}", "blog", prompt: "Blog"
            item.add_link "/blogs/#{friend['id']}", "avatar", prompt: "Avatar", render: 'image'
          end
        end
        builder.add_query("/friends/search", "search", prompt: "Search") do |query|
          query.add_data "search"
        end
        builder.set_template do |template|
          template.add_data "full-name", prompt: "Full Name"
          template.add_data "email", prompt: "Email"
          template.add_data "blog", prompt: "Blog"
          template.add_data "avatar", prompt: "Avatar"
        end
      end

      expect(response.version).to eq('1.1')
      expect(response.page_info.current_page).to eq(1)
      expect(response.page_info.total_items).to eq(10)
      expect(response.page_info.total_records).to eq(1000)
      expect(response.page_info.page_size).to eq(2)
      expect(response.href).to eq('/friends/')
      expect(response.links.first.href).to eq("/friends/rss")
      expect(response.link('feed').href).to eq("/friends/rss")
      expect(response.items.length).to eq(3)
      expect(response.items.first.data.length).to eq(2)
      expect(response.items.first.datum('full-name').value).to eq("J. Doe")
      expect(response.items.first.links.length).to eq(2)
      expect(response.items.first.href.class).to eq(String)
      expect(response.template.data.length).to eq(4)
      expect(response.queries.length).to eq(1)
      expect(response.queries.first.href).to eq("/friends/search")
      expect(response.queries.first.data.length).to eq(1)
      expect(response.queries.first.data.first.name).to eq('search')
      expect(response.query('search').prompt).to eq('Search')
    end
  end

  describe :parse do
    before(:all) do
      json = '{"collection": {

        "href": "http://www.example.org/friends",
        "version": "1.1",
        "page_info": { "current_page": 1, "total_items": 10, "page_size": 2},
        "links": [
          {"rel": "feed", "href": "http://www.example.org/friends.rss"}
        ],
        "items": [
          {
            "href": "http://www.example.org/m.rowe",
            "data": [
              {"name": "full-name", "value": "Matt Rowe"}
            ]
          }
        ]
      }}'
      @collection = CollectionJSON.parse(json)
    end

    it 'should parse JSON into a Collection' do
      expect(@collection.class).to eq(CollectionJSON::Collection)
    end

    it 'should have correct href' do
      expect(@collection.href).to eq("http://www.example.org/friends")
    end

    it 'should have the correct version' do
      expect(@collection.version).to eq("1.1")
    end

    it 'should have the correct page info' do
      expect(@collection.page_info).not_to be_nil
      expect(@collection.page_info.current_page).to eq(1)
      expect(@collection.page_info.total_items).to eq(10)
      expect(@collection.page_info.page_size).to eq(2)
    end

    it 'should handle the nested attributes' do
      expect(@collection.items.first.href).to eq("http://www.example.org/m.rowe")
      expect(@collection.items.first.data.count).to eq(1)
    end

    it 'should be able to be reserialized' do
      expect(@collection.to_json.class).to eq(String)
    end

    it 'should have the correct link' do
      expect(@collection.links.first.href).to eq("http://www.example.org/friends.rss")
    end
  end
end
