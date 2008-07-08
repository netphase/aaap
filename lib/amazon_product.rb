require 'hpricot'

class AmazonProduct < ActiveRecord::Base

  def get(key, separator = ', ')
    @doc ||= Hpricot.XML(xml)
    values = (@doc/key).collect {|e| e.inner_html }
    values *= separator unless separator.nil?
    values unless values.blank?
  end

  def isbn
    get("itemattributes/isbn")
  end

  def title
    get("itemattributes/title")
  end

  def author
    get("itemattributes/author")
  end

  def binding
    get("itemattributes/binding")
  end

  def price
    get("itemattributes/listprice/amount")
  end

  def pages
    get("itemattributes/numberofpages")
  end

  def small_image_url
    get("smallimage/url")
  end

  def medium_image_url
    get("mediumimage/url")
  end

  def large_image_url
    get("largeimage/url")
  end

  def detail_url
    get("detailpageurl")
  end
end