require 'rubygems'
require 'active_record'
require 'amazon/ecs'
require 'amazon_product'

module Netphase
  module Acts #:nodoc:
    module Amazonable #:nodoc:

      def self.included(base)
        base.extend ClassMethods  
      end

      module ClassMethods
        def acts_as_amazon_product(options = {})
          defaults = {
            :asin => 'asin',
            :name => 'name',
            :access_key => ENV['AMAZON_ACCESS_KEY_ID'],
            :associate_tag => ENV['AMAZON_ASSOCIATE_TAG'],
            :search_index => 'Books'
          }
          options = defaults.merge options

          Amazon::Ecs.options = {:aWS_access_key_id => options[:access_key], :associate_tag => options[:associate_tag] }

          write_inheritable_attribute(:amazon_asin, options[:asin])    
          write_inheritable_attribute(:amazon_name, options[:name])
          write_inheritable_attribute(:amazon_search_index, options[:search_index])    
          write_inheritable_attribute(:amazon_associate_key, options[:associate_key])
          class_inheritable_reader :amazon_asin, :amazon_name, :amazon_search_index, :amazon_associate_key
          
          has_one :amazon_product, :as => :amazonable   #, :dependent => :delete
          include Netphase::Acts::Amazonable::InstanceMethods
        end
      end
      
      # This module contains instance methods
      module InstanceMethods
        def amazon
          if self.amazon_product.nil?
            asin = self.send(self.amazon_asin)
            name = self.send(self.amazon_name)
            
            if !asin.blank?
              options = { :response_group => 'Medium' }
              unless self.amazon_asin == 'asin'
                options[:id_type] = self.amazon_asin.upcase
                options[:search_index] = self.amazon_search_index
              end
              res = Amazon::Ecs.item_lookup(self.send(self.amazon_asin), options)
              self.create_amazon_product(:xml => res.doc.to_html, :asin => res.doc.at('asin').inner_html)
            elsif !name.blank?
              res = Amazon::Ecs.item_search(self.send(self.amazon_name), :search_index => self.amazon_search_index, :response_group => 'Medium')
              res = res.doc.at('items/item')
              self.create_amazon_product(:xml => res.to_html,
                :asin => (res.at('itemattributes/isbn').nil? ? res.at('asin').inner_html : res.at('itemattributes/isbn').inner_html))
            else
              logger.error "No known attributes to search by"
            end            
          end
          self.amazon_product
        end

        def after_save
          unless self.amazon_product.nil?
            self.amazon_product.destroy
            self.reload
          end
        end
      end
    end
  end
end

ActiveRecord::Base.class_eval do
  include Netphase::Acts::Amazonable
end

