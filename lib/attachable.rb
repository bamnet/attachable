# Attachable
require 'attachable/version'
require 'active_record'
require 'action_controller'

# Attachable provides simple file upload handlers for Rails 3 models.
module Attachable

  module ClassMethods

    # Loads the attachable methods, scope, and config into the model.
    def attachable(options = {})
      # Store the default prefix for file data
      # Defaults to "file"
      cattr_accessor :attachment_file_prefix
      self.attachment_file_prefix = (options[:file_prefix] || :file).to_s
      
      # Setup the default scope so the file data isn't included by default.
      # Generate the default scope, which includes every column except for the data column.
      # We use this so queries, by default, don't include the file data which could be quite large.
      default_scope { select(column_names.reject { |n| n == "#{attachment_file_prefix}_data" }.collect {|n| "#{table_name}.#{n}" }.join(',')) }
      
      # Include all the important stuff
      include InstanceMethods
    end
  end
  
  module InstanceMethods
  
    # Read the file data back from where ever it is stored.  Uses a cached copy if it exists.
    # If the cached attribute doens't exist, it reloads the model to get it 
    def file_contents
      #Try to hit the cache, reload if it fails
      if !attribute_present?("#{attachment_file_prefix}_data")
        reload :select => "#{attachment_file_prefix}_data"
      end
      send("#{attachment_file_prefix}_data")
    end
  
    # Take in a UploadFile and copy it's properties to four fields,
    # data, size, original filename.  An UploadFile wraps a Tempfile,
    # but includes some extra data (like the original filename and 
    # content type).  We can't garuntee this file to be at the beginning,
    # so we always rewind it.
    def file=(tempfile)
      tempfile.rewind #This may not be super efficient, but it's the necessary fix for Rails 3.1
      self["#{attachment_file_prefix}_data"] = tempfile.read
      
      size = nil
      if tempfile.respond_to?(:size)
        size = tempfile.size
      elsif tempfile.respond_to?(:stat)
        size = tempfile.stat.size
      end
      self["#{attachment_file_prefix}_size"] = size unless size.nil?

      filename = nil
      if tempfile.respond_to?(:original_filename)
        filename = tempfile.original_filename        
      elsif tempfile.respond_to?(:path)
        filename = File.basename(tempfile.path)
      end
      self["#{attachment_file_prefix}_name"] = filename unless filename.nil?

      self["#{attachment_file_prefix}_type"] = tempfile.content_type if tempfile.respond_to?(:content_type)
    end
  end
  
end

# Rails 3 compatability?
if defined? Rails
  ActiveRecord::Base.class_eval do
    extend Attachable::ClassMethods
  end
end
