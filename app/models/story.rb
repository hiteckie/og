class Story
  include Mongoid::Document

  field :story_id, :type => String
  field :og_action, :type => String
  field :og_type, :type => String
  field :og_url, :type => String
end