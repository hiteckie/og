class StoryController < ApplicationController

  def index
    logger.info request.params
    #render :text => "Let's publish some actions!"
  end

  def test
    render :text => "Hello world!"
  end

  def new_article
    a = Article.new
    a.content = "hello there: #{Time.now.to_s}"
    a.name = "yes"
    a.save
    render :text =>"Success!!"
  end

  def get_article
    all_a = Article.find(:all)
    a_str = ""
    all_a.each { |x|
      a_str += x.content + "\n<br>"
    }
    render :text => "#{a_str}"
  end

  def og_obj

  end

  def test_user
    a = AppUser.new
    a.uid = '123456'
    a.access_token = 'r708whfshafjksd'
    a.name = 'name1'
    a.save
    render :text => 'success!'
  end

  def get_users
    users = AppUser.find(:all)
    list = ""
    i = 1
    users.each { |u|
      list += i.to_s + ") " + u.name + ", " + u.uid + ", " + u.access_token + "<br>"
      i += 1
    }
    logger.info "Count: " + users.count.to_s
    render :text => "#{list}"
  end

end
