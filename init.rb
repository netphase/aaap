# Include hook code here
require 'acts_as_amazon_product'
ActiveRecord::Base.send(:include, Netphase::Acts::Amazonable)
