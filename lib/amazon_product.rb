require 'hpricot'

class AmazonProduct < ActiveRecord::Base
#  belongs_to :amazonable, :polymorphic => true

  def hdoc(key, separator = ', ')
    @doc ||= Hpricot.XML(xml)
    values = (@doc/key).collect {|e| e.inner_html }
    values *= separator unless separator.nil?
    values unless values.blank?
  end

  def get(key)
    hdoc(key)
  end

  def isbn
    hdoc("itemattributes/isbn")
  end

  def title
    hdoc("itemattributes/title")
  end

  def author
    hdoc("itemattributes/author")
  end

  def binding
    hdoc("itemattributes/binding")
  end

  def price
    hdoc("itemattributes/listprice/amount")
  end

  def pages
    hdoc("itemattributes/numberofpages")
  end

  def small_image_url
    hdoc("smallimage/url")
  end

  def medium_image_url
    hdoc("mediumimage/url")
  end

  def large_image_url
    hdoc("largeimage/url")
  end

  def detail_url
    hdoc("detailpageurl")
  end
end