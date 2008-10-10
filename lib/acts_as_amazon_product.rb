# ActsAsAmazonProduct

require 'rubygems'
#require 'active_support'
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
          extend Netphase::Acts::Amazonable::SingletonMethods
        end
                
      end
      
      # This module contains class methods
      module SingletonMethods
        
      end
      
      # This module contains instance methods
      module InstanceMethods
        
        def amazon
          if self.amazon_product.nil?
            asin = (self.respond_to?('amazon_asin')) ? self.send(self.amazon_asin) : nil
            name = (self.respond_to?('amazon_name')) ? self.send(self.amazon_name) : nil
            search_index = (self.respond_to?('amazon_search_index')) ? self.amazon_search_index : 'Books'
            
            begin
              if !asin.blank?
                # puts "Looking up #{asin}"
                res = Amazon::Ecs.item_lookup(self.send(self.amazon_asin), :response_group => 'Medium')
              
                self.amazon_product =
                  AmazonProduct.new(:xml => res.doc.to_html, :asin => res.doc.at('asin').inner_html)
                self.amazon_product.save
              elsif !name.blank?
                # puts "Searching for #{name}"
                res = Amazon::Ecs.item_search(self.send(self.amazon_name), 
                  :search_index => self.amazon_search_index, :response_group => 'Medium') #, :sort => 'salesrank'
                res = res.doc.at('items/item')
                self.amazon_product =
                  AmazonProduct.new(:xml => res.to_html, 
                    :asin => (res.at('itemattributes/isbn').nil? ? 
                      res.at('asin').inner_html : res.at('itemattributes/isbn').inner_html))
                self.amazon_product.save
              else
                logger.error "No known attributes to search by"
              end            
            rescue
              puts "Amazon lookup failed: $!"
              self.amazon_product = AmazonProduct.new(:xml => "")
            end
          end
          self.amazon_product
        end
        
        #def method_missing(method, *args)
        #end

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

