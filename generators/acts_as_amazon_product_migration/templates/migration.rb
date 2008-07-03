class ActsAsAmazonProductMigration < ActiveRecord::Migration
  def self.up
    create_table :amazon_products do |t|
  	  t.string  :asin
  	  t.text    :xml
  	  t.integer :amazonable_id, :default => 0, :null => false
  	  t.string  :amazonable_type, :limit => 15, :default => "", :null => false
  	  
  	  t.timestamps
  	end
  end
  
  def self.down
    drop_table :amazon_products
  end
end
