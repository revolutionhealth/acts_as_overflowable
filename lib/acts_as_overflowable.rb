module ActiveRecord
  module Acts
    module Overflowable 
      
      def self.included(base)
        base.extend(ClassMethods)  
      end
      
      #Available options
      # :column - the column in the model that may have overflow.
      # :overflow_limit - the maximum length of the column before it is saved as overflow
      # :has_overflow_column - not a boolean. The model must have a flag denoting whether there is overflow. This option tells the
      #				the plugin what the column name of the flag is.
      module ClassMethods
        def acts_as_overflowable(options = {})
          this_class = ActiveRecord::Base.send(:class_name_of_active_record_descendant, self).to_s
          raise "No overflow column supplied in acts as overflowable for #{this_class}." if not options[:overflow_column]
          raise "No overflow_limit option supplied in acts as overflowable for #{this_class}." if not options[:overflow_limit]
          raise "No overflow_indicator option supplied in acts as overflowable for #{this_class}." if not options[:overflow_indicator]
          raise "No overflow_table option supplied in acts as overflowable for #{this_class}." if not options[:overflow_table]
          
          overflow_column = options[:overflow_column]
          overflow_indicator = options[:overflow_indicator]
          overflow_table = options[:overflow_table]
		  overflow_limit = options[:overflow_limit]
          
          class_inheritable_reader :options

		  has_one overflow_table,
		  		  :foreign_key => :overflowable_id,
        	   	  :conditions => ['overflowable_type = ?',this_class],
        	   	  :dependent => :destroy
          
          options.keys.each do |key|		    
			class_eval "def #{key.to_s}() \"#{options[key]}\" end"
		  end
		  
		  class_eval <<-EOV
		  	#getter for the overflowable_text field. Dynamic, so it can be named anything.
		    def #{overflow_column.to_s}_with_overflow()
		    	has_overflow = self.send("#{overflow_indicator}")
		    	if has_overflow
		    		self.send("#{overflow_table}").overflow 
		    	else
		    		self[:#{overflow_column}]
		    	end
		    end 
		    
        def #{overflow_column.to_s}=(value)
		      limit = overflow_limit.to_i
          overflow_model = self.send("#{overflow_table}")
		    	if (not value.nil?) and (value.length >= (limit-1))
		    		if overflow_model.nil?
		    			self.send("create_#{overflow_table}", :overflowable_type => "#{this_class}")
		    		end
            overflow_model = self.send("#{overflow_table}")
		    		overflow_field = overflow_model.overflow
		    		if overflow_field.nil? or (value.length > limit and !overflow_field.eql?(value))
			    		self.send("#{overflow_table}").overflow = value
				    	self.send("#{overflow_indicator}=",true)
				    	self[:#{overflow_column}] = value[0..(limit-1)]
				    	overflow_model.save! unless self.new_record?
				    end
				  else
            overflow_model.overflow = "" unless overflow_model.nil?
		    		self[:#{overflow_column}] = value
		    		self.send("#{overflow_indicator}=",false)
		    		overflow_model.save! if !overflow_model.nil? and !self.new_record?
		      end
        end
		  EOV
		  
		  include InstanceMethods
          extend SingletonMethods  
        end
      end #ClassMethods
      
      module SingletonMethods
      end
      
      module InstanceMethods
      end #InstanceMethods

    end
  end
end

ActiveRecord::Base.send(:include, ActiveRecord::Acts::Overflowable)
