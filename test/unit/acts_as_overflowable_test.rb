require File.join(File.dirname(__FILE__), '../test_helper')

class Overflowable < ActiveRecord::Base
  acts_as_overflowable :overflow_column => :overflowable_text, 
  					   :overflow_limit => 50, 
  					   :overflow_indicator => :has_overflow, 
  					   :overflow_table => :overflow
end

class Overflow < ActiveRecord::Base
end

HUNDRED_CHARS = "0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789"
HUNDRED_LETTERS = "qwertyuiopasdfghjklzxcvbnqwertyuiopasdfghjklzxcvbnqwertyuiopasdfghjklzxcvbnqwertyuiopasdfghjklzxcvbn"
FORTY_CHARS = "0123456789012345678901234567890123456789"

class ActsAsOverflowableTest < Test::Unit::TestCase
  
  include ActiveRecordTestHelper

  def setup
    ar_setup()
    ActiveRecord::Schema.define(:version => 1) do      
      create_table :overflowables do |t|
        t.boolean :has_overflow
        t.string :overflowable_text
        t.timestamps
      end
      
      create_table :overflows do |t|
        t.integer :overflowable_id
        t.string :overflowable_type
        t.string :overflow
        t.timestamps
      end
    end
  end

  def teardown
    ar_teardown()
  end

  def test_that_overflowable_options_are_processed_correctly
    overflowable = Overflowable.new(:overflowable_text => HUNDRED_CHARS)
    
    assert_equal "overflowable_text", overflowable.overflow_column
    assert_equal "50", overflowable.overflow_limit
    assert_equal "has_overflow", overflowable.overflow_indicator
    assert_equal "overflow", overflowable.overflow_table
  end
  
  def test_that_content_not_needing_truncation_is_saved_only_in_overflowable_table
  	overflowable = Overflowable.create!(:overflowable_text => FORTY_CHARS)
    
    assert_not_nil overflowable.id
    assert !overflowable.has_overflow
    assert_nil overflowable.overflow
    assert_equal overflowable.overflowable_text, FORTY_CHARS
  end
  
  def test_that_truncated_overflow_field_is_saved_in_the_overflow_table
  	overflowable = Overflowable.create!(:overflowable_text => HUNDRED_CHARS)
    
    assert_not_nil overflowable.id
    assert overflowable.has_overflow
    assert_equal overflowable.overflow.overflow, HUNDRED_CHARS
    assert_equal overflowable.overflowable_text_with_overflow, HUNDRED_CHARS
  end  
  
  def test_that_overflow_is_updated_when_original_content_id_updated
  	overflowable = Overflowable.create!(:overflowable_text => HUNDRED_CHARS)
  	assert_equal overflowable.overflowable_text_with_overflow, HUNDRED_CHARS
  	
  	overflowable.overflowable_text = HUNDRED_LETTERS
  	overflowable.save
  	overflowable.save
  	
  	assert_equal overflowable.overflowable_text_with_overflow, HUNDRED_LETTERS
  	assert_equal 100, overflowable.overflowable_text_with_overflow.length
  end
  
  def test_that_overflow_is_erased_when_size_of_overflowable_text_field_becomes_less_than_limit
  	overflowable = Overflowable.create!(:overflowable_text => HUNDRED_CHARS)
  	assert_equal overflowable.overflowable_text_with_overflow, HUNDRED_CHARS
  	
  	overflowable.overflowable_text = FORTY_CHARS
  	overflowable.save
  	
  	assert_equal overflowable.overflowable_text, FORTY_CHARS
  	assert_equal 40, overflowable.overflowable_text.length
  	
  	assert_equal "", Overflow.find(:all).last.overflow
  end
  
  def test_that_short_field_id_updated_to_longer_value
    overflowable = Overflowable.create!(:overflowable_text => FORTY_CHARS)
    assert_equal overflowable.overflowable_text, FORTY_CHARS
    
    overflowable.overflowable_text = HUNDRED_CHARS
    overflowable.save
    
    assert_equal HUNDRED_CHARS[0..49], overflowable.overflowable_text
    assert_equal HUNDRED_CHARS, overflowable.overflowable_text_with_overflow 
  end
  
end
