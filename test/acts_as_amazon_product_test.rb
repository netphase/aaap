require 'test/unit'
require 'yaml'

require File.expand_path(File.dirname(__FILE__) + "/../lib/acts_as_amazon_product")

#require File.expand_path(File.dirname(__FILE__) + "/../init")

config = open(File.dirname(__FILE__) + "/../test/config.yml") { |f| YAML.load(f.read)}
ActiveRecord::Base.establish_connection(config["database"])

#Amazon::Ecs.options = {:aWS_access_key_id => config['amazon']['access_key']}
@@access_key = config['amazon']['access_key']
@@associate_tag = config['amazon']['associate_tag']

ActiveRecord::Base.connection.drop_table :amazon_products rescue nil
ActiveRecord::Base.connection.drop_table :books rescue nil
ActiveRecord::Base.connection.drop_table :movies rescue nil
ActiveRecord::Base.connection.drop_table :magazines rescue nil

ActiveRecord::Base.connection.create_table :books do |t|
  t.column :title, :string
  t.column :author, :string
  t.column :isbn, :string  
end

ActiveRecord::Base.connection.create_table :movies do |t|
  t.column :name, :string
  t.column :asin, :string
end

ActiveRecord::Base.connection.create_table :magazines do |t|
  t.column :name, :string
  t.column :asin, :string
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

class Movie < ActiveRecord::Base
  acts_as_amazon_product :access_key => @@access_key, :associate_tag => @@associate_tag
end

class Magazine < ActiveRecord::Base
  acts_as_amazon_product :search_index => 'Magazines', :access_key => @@access_key,
    :associate_tag => @@associate_tag
end

AmazonProduct.delete_all

class ActAsAmazonProductTest < Test::Unit::TestCase
    
  def setup
    Book.delete_all        
    @book_gtd = Book.create(:title => 'Getting Things Done', :author => 'Dude', :isbn => '0142000280')
    @book_ror = Book.create(:title => 'Rails Recipes')
    @book_perl = Book.create(:title => 'Perl')
    @movie_dh = Movie.create(:name=>'Live Free or Die Hard', :asin=>'B000VNMMRA')
    Magazine.delete_all
    @mag_lci = Magazine.create(:name => 'La Cucina Italiana')
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
    assert_equal("Advanced Rails Recipes: 84 New Ways to Build Stunning Rails Apps (Pragmatic Programmers)", @book_ror.amazon.title)
    assert_equal("Mike Clark", @book_ror.amazon.author)
  end
  
  def test_returns_nil_if_attribute_not_found
    assert_equal(nil, @book_ror.amazon.get('contributor'))
  end
  
  def test_update
    assert_not_nil(@book_perl.amazon)
    isbn = @book_perl.amazon.isbn
    @book_perl.title = "Websters"
    @book_perl.save
    assert_not_equal(isbn, @book_perl.amazon.isbn)
  end
  
  def test_product_with_all_defaults
    assert_not_nil(@movie_dh.amazon)
    assert_equal 'Bruce Willis, Timothy Olyphant, Justin Long, Maggie Q, Cliff Curtis',
      @movie_dh.amazon.get('itemattributes/actor')
  end
  
  def test_accepts_a_custom_separator
    assert_equal 'Bruce Willis | Timothy Olyphant | Justin Long | Maggie Q | Cliff Curtis',
      @movie_dh.amazon.get('itemattributes/actor', ' | ')      
  end
  
  def test_returns_array_if_separator_is_nil
    assert_equal ['Bruce Willis', 'Timothy Olyphant', 'Justin Long', 'Maggie Q', 'Cliff Curtis'],
      @movie_dh.amazon.get('itemattributes/actor', nil)      
  end

  def test_method_missing
    assert_equal 'Bruce Willis, Timothy Olyphant, Justin Long, Maggie Q, Cliff Curtis', @movie_dh.amazon.actor
  end

  def test_method_missing_with_separator
    assert_equal 'Bruce Willis | Timothy Olyphant | Justin Long | Maggie Q | Cliff Curtis', @movie_dh.amazon.actor(' | ')
  end
end
