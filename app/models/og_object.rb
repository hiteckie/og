class OgObject
  include Mongoid::Document

  field :url, :type => String
  field :og_type, :type => String
  field :og_title, :type => String
  field :og_description, :type => String
  field :og_image, :type => String
end