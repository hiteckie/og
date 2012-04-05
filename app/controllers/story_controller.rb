class StoryController < ApplicationController

  def index
    render :text => "Let's publish some actions!"
  end

  def test
    render :text => "Hello world!"
  end

end
