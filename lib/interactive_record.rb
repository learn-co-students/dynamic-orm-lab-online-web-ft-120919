require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
    def initialize(attrs={})
        attrs.each do |key, value|
            # binding.pry 
            self.send("#{key}=", value)
        end
        
    end
end