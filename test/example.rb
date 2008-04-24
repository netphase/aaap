$: << 'lib'

require 'acts_as_amazon_product'

ActiveRecord::Base.establish_connection({:adapter => 'sqlite3', :database => 'test.db'})
ActiveRecord::Base.connection.create_table :books, :force => true do |t|
  t.column :name, :string
  t.column :asin, :string
end


class Book < ActiveRecord::Base
  acts_as_amazon_product
end


book = Book.create(:name => 'Rails Recipes')

puts <<EOS
   Title:   #{book.amazon.title}
   Author:  #{book.amazon.author}
   Price:   #{book.amazon.price}
   Image:   #{book.amazon.small_image_url}
   Details: #{book.amazon.detail_url}
EOS



