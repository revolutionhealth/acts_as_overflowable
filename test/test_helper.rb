RAILS_ENV = 'test' if !defined?(RAILS_ENV) || RAILS_ENV != 'test'
require 'test/unit'
require 'rubygems'
 
require File.join(File.dirname(__FILE__), 'active_record_test_helper')
 
require File.dirname(__FILE__) + '/../lib/acts_as_overflowable'
 
require 'mocha'
#require File.join(File.dirname(__FILE__), 'seo_test_model')
#require File.join(File.dirname(__FILE__), 'seo_test_model_conditions')
