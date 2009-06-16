require 'test/unit'
require 'yaml'

require File.expand_path(File.dirname(__FILE__) + "/../lib/acts_as_amazon_product")

require File.expand_path(File.dirname(__FILE__) + "/../init")

config = open(File.dirname(__FILE__) + "/../test/config.yml") { |f| YAML.load(f.read)}
ActiveRecord::Base.establish_connection(config["database"])

#Amazon::Ecs.options = {:aWS_access_key_id => config['amazon']['access_key']}
@@access_key = config['amazon']['access_key']
@@associate_tag = config['amazon']['associate_tag']

ActiveRecord::Base.connection.drop_table :amazon_products rescue nil
ActiveRecord::Base.connection.drop_table :books rescue nil
ActiveRecord::Base.connection.drop_table :ean_books rescue nil
ActiveRecord::Base.connection.drop_table :movies rescue nil
ActiveRecord::Base.connection.drop_table :magazines rescue nil
ActiveRecord::Base.connection.drop_table :local_books rescue nil

ActiveRecord::Base.connection.create_table :books do |t|
  t.column :type, :string
  t.column :title, :string
  t.column :author, :string
  t.column :isbn, :string
  t.column :ean, :string
end

ActiveRecord::Base.connection.create_table :movies do |t|
  t.column :name, :string
  t.column :asin, :string
end

ActiveRecord::Base.connection.create_table :magazines do |t|
  t.column :name, :string
  t.column :asin, :string
end

ActiveRecord::Base.connection.create_table :local_books do |t|
  t.column :title, :string
  t.column :author, :string
  t.column :isbn, :string 
  t.column :publisher_name, :string 
  t.column :small_image_url, :string
  t.column :medium_image_url, :string
end

ActiveRecord::Base.connection.create_table :amazon_products do |t|  # , :id => false
  t.column :asin, :string
  t.column :xml, :text
  t.column :created_at, :datetime, :null => false
  t.column :amazonable_id, :integer, :default => 0, :null => false
  t.column :amazonable_type, :string, :limit => 15, :default => "", :null => false
end

class Book < ActiveRecord::Base
  acts_as_amazon_product(
    :asin => 'isbn', :name => 'title', 
    :access_key => @@access_key, :associate_tag => @@associate_tag)
end

class EANBook < Book
  acts_as_amazon_product(
    :asin => 'ean', :name => 'title',
    :access_key => @@access_key, :associate_tag => @@associate_tag)
end

class Movie < ActiveRecord::Base
  acts_as_amazon_product :access_key => @@access_key, :associate_tag => @@associate_tag
end

class Magazine < ActiveRecord::Base
  acts_as_amazon_product :search_index => 'Magazines', :access_key => @@access_key,
    :associate_tag => @@associate_tag
end

class LocalBook < ActiveRecord::Base
  acts_as_amazon_product(
    :asin => 'isbn', :name => 'title', 
    :access_key => @@access_key, :associate_tag => @@associate_tag, :ignore_fields => [:small_image_url, :medium_image_url]
  ) 
end

AmazonProduct.delete_all

class ActAsAmazonProductTest < Test::Unit::TestCase
    
  def setup
    Book.delete_all        
    @book_gtd = Book.create(:title => 'Getting Things Done', :author => 'Dude', :isbn => '0142000280')
    @book_ror = Book.create(:title => 'Rails Recipes')
    @book_perl = Book.create(:title => 'Perl')
    @book_eg = EANBook.create(:ean => '9780765342294')
    @movie_dh = Movie.create(:name=>'Live Free or Die Hard', :asin=>'B000VNMMRA')
    @mag_lci = Magazine.create(:name => 'La Cucina Italiana')
    LocalBook.delete_all
    @local_rails = LocalBook.load_from_amazon('1590598415')
    @local_roots = LocalBook.load_from_amazon!('Roots', true)
  end
  
  def test_isbn
    assert_not_nil(@book_gtd.amazon)
    assert_equal("0142000280", @book_gtd.amazon.isbn)
  end
  
  def test_title
    assert_not_nil(@book_gtd.amazon)
    assert_equal("Getting Things Done: The Art of Stress-Free Productivity", @book_gtd.amazon.title)
  end
  
  def test_magazine
    assert_not_nil(@mag_lci.amazon)
    assert_equal("B00009XFML", @mag_lci.amazon.asin)
  end
  
  def test_lookup_by_nonstandard_id
    assert_not_nil(@book_eg.amazon)
    assert_equal("Ender's Game", @book_eg.amazon.title)
  end

  def test_invalid_isbn
    b = Book.create(:isbn => '12345')
    assert_nil(b.amazon)
  end

  def test_invalid_title
    b = Book.create(:title => "AQAQAQAQ")
    assert_nil(b.amazon)
  end

  def test_small_image
    assert_not_nil(@book_gtd.amazon)
    assert_match(/4104N6ME70L\._SL75_\.jpg/, @book_gtd.amazon.small_image_url)
  end
  
  def test_author
    assert_not_nil(@book_gtd.amazon)
    assert_equal("David Allen", @book_gtd.amazon.author)
  end
  
  def test_binding
    assert_not_nil(@book_gtd.amazon)
    assert_equal("Paperback", @book_gtd.amazon.binding)
  end
  
  def test_find_with_multiple
    assert_equal("Advanced Rails Recipes", @book_ror.amazon.title)
    assert_equal("Mike Clark", @book_ror.amazon.author)
  end
  
  def test_returns_nil_if_attribute_not_found
    assert_equal(nil, @book_ror.amazon.get('contributor'))
  end
  
  def test_update
    assert_not_nil(@book_perl.amazon)
    isbn = @book_perl.amazon.isbn
    @book_perl.title = "Websters"
    @book_perl.amazon.destroy
    @book_perl.save
    assert_not_equal(isbn, @book_perl.reload.amazon.isbn)
  end
  
  def test_product_with_all_defaults
    assert_not_nil(@movie_dh.amazon)
    assert_equal 'Bruce Willis, Justin Long, Timothy Olyphant, Maggie Q, Cliff Curtis',
      @movie_dh.amazon.get('itemattributes/actor')
  end
  
  def test_accepts_a_custom_separator
    assert_equal 'Bruce Willis | Justin Long | Timothy Olyphant | Maggie Q | Cliff Curtis',
      @movie_dh.amazon.get('itemattributes/actor', ' | ')      
  end
  
  def test_returns_array_if_separator_is_nil
    assert_equal ["Bruce Willis", "Justin Long", "Timothy Olyphant", "Maggie Q", "Cliff Curtis"],
      @movie_dh.amazon.get('itemattributes/actor', nil)      
  end

  def test_method_missing
    assert_equal 'Bruce Willis, Justin Long, Timothy Olyphant, Maggie Q, Cliff Curtis', @movie_dh.amazon.actor
  end

  def test_method_missing_with_separator
    assert_equal 'Bruce Willis | Justin Long | Timothy Olyphant | Maggie Q | Cliff Curtis', @movie_dh.amazon.actor(' | ')
  end
  
  def test_load_local_book
    assert_not_nil(@local_rails.title)
    assert_not_nil(@local_rails.isbn)
    assert_not_nil(@local_rails.publisher_name)
    assert_not_nil(@local_rails.author)
    assert_not_nil(@local_roots.title)
    assert_not_nil(@local_roots.isbn)
    assert_not_nil(@local_roots.publisher_name)
    assert_not_nil(@local_roots.author)
    assert_equal "Practical Rails Social Networking Sites (Expert's Voice)", @local_rails.title
    assert_equal '0882667033', @local_roots.isbn
  end
  
  def test_new_versus_saved_load 
    assert_equal @local_rails.new_record?, true
    assert_equal @local_roots.new_record?, false
  end
  
  def test_lack_of_initial_amazon_product_for_local
    @local_woody = LocalBook.load_from_amazon!('0736412662')
    assert_nil AmazonProduct.find_by_amazonable_id(@local_woody.id)
  end
  
  def test_ignore_fields
    assert_nil @local_rails.small_image_url
    assert_nil @local_rails.medium_image_url
    assert_nil @local_roots.small_image_url
    assert_nil @local_roots.medium_image_url
  end
  
  def test_locals_load_amazon_attributes_if_needed
    assert_not_nil @local_rails.amazon.binding
    assert_not_nil @local_roots.amazon.binding
    assert_equal @local_rails.amazon.binding, 'Paperback'
    assert_equal @local_roots.amazon.binding, 'Paperback'
  end
  
end
