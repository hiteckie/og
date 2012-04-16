class AppUser
  include Mongoid::Document

  field :name, :type => String
  field :access_token, :type => String
  field :uid, :type => String
end