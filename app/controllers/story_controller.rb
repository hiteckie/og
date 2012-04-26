class StoryController < ApplicationController

  def index
    logger.info request.params
    @obj = false
    if params[:do_action] == 'prefill'
      @obj = OpenGraph.fetch(params['og:url'])
      if @obj
        logger.info "og:url: " + params['og:url']
        logger.info "Obj: " + @obj.to_s
        @obj.keys.each { |x|
          logger.info "og:" + x + " : " + @obj[x]
        }
      end
    end
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
    @og_type = params[:og_type] ? params[:og_type] : 'article'
    @og_url = request.url
    @og_title = params[:og_title] ? params[:og_title] : 'Default title'
    @og_description = params[:og_description] ? params[:og_description] : 'Default description'
    @og_image = params[:og_image] ? params[:og_image] : 'http://ogp.me/logo.png'
    logger.info "og_url: " + @og_url
    render :layout => nil
  end

  def ext_og_obj_id
    new_obj = OgObject.find(params[:id])
    logger.info "\nYESYES: " + new_obj.url
    @obj = OpenGraph.fetch(new_obj.url)
    if @obj
      @obj['url'] = "http://ogapp.herokuapp.com/story/ext_og_obj_id/" + new_obj.id.to_s
      logger.info "og:url: " + new_obj.url.to_s
      logger.info "Obj: " + @obj.to_s
      @orig_url = new_obj.url
      @obj.keys.each { |x|
        logger.info "og:" + x + " : " + @obj[x]
      }
    else
      @obj = []
    end
    @top_obj_type = @obj['type']
    if @obj['type'] == 'video.other'
      @top_obj_type = 'video'
    end

    render :layout => nil
  end

  def ext_og_obj
    new_obj = OgObject.where(url: params['og:url'])
    og_obj = nil
    if new_obj != []
      logger.info "URL OBJ FOUND: " + new_obj.first.id.to_s
      og_obj = new_obj.first
    else
      logger.info "URL OBJ NOT FOUND!!!!"
      new_obj = OgObject.new
      new_obj.url = params['og:url']
      new_obj.save
      og_obj = new_obj
    end

    if og_obj != nil
      redirect_to "/story/ext_og_obj_id?id=" + og_obj.id.to_s
    else
      render :layout => nil
    end
  end

  def publish_obj_action

  end

  def publish_action
    if session[:graph_api] != nil

      app = session[:graph_api].get_object(APP_ID)
      app_namespace = app['namespace']
      logger.info "App namespace: " + app['namespace']
      og_url = "http://ogapp.herokuapp.com/story/ext_og_obj?og:url=" + params[:'og:url']
      @obj = OpenGraph.fetch(params['og:url'])
      if @obj
        logger.info "og:url: " + params['og:url']
        logger.info "Obj: " + @obj.to_s
        @obj.keys.each { |x|
          logger.info "og:" + x + " : " + @obj[x]
        }
      end

      #pub_id = pub_backend(params['action'], obj, params['url'])
      #og_url += "&content_url=" + params[:content_url]
      #og_url = params['og:url']
      obj_type =  @obj['type']
      obj_type = 'video'
      logger.info "publish_action OG_URL: " + @obj['type'] + ':' + og_url
      pub_id = session[:graph_api].put_connections("me", "#{app_namespace}:#{params['og:action']}", "#{obj_type}" => og_url)
      logger.info "App namespace: " + app['namespace'] + ", pub_id: " + pub_id.first.to_s

    else
      logger.info "graph_api not inited"
    end
  end

  def parse_og
    url = params["og:url"]
    return parse_og_backend(url)
  end

  def parse_og_backend(url)
    og_action = params["og:action"]
    @obj = nil
    if url != nil
      @obj = OpenGraph.fetch(url)
      logger.info "Obj fetched: " + @obj.to_s
    else
      logger.info "url is empty"
    end
  end

  def pub_backend(og_action, obj, content_url)
    pub_id = "NOTHING"
    if session[:graph_api] != nil

      app = session[:graph_api].get_object(APP_ID)
      app_namespace = app['namespace']
      logger.info "App namespace: " + app['namespace']
      og_url = "http://ogapp.herokuapp.com/story/og_obj?"
      obj.keys.each { |k|
        og_url += "&og:" + k + "=" + obj[k]
      }
      og_url += "&content_url=" + content_url
      logger.info "og_url: " + og_url
      pub_id = session[:graph_api].put_connections("me", "#{app_namespace}:#{og_action}", obj['type'] => og_url)
      logger.info "App namespace: " + app['namespace'] + ", pub_id: " + pub_id.first.to_s

    else
      logger.info "graph_api not inited"
    end
    return pub_id
  end

  def persist_user
    u = AppUser.where(:uid => params[:uid])
    logger.info "Num existing users: " + u.count.to_s
    logger.info "User uid: #{params[:uid]}, #{params[:name]}, #{params[:access_token]}"
    user = u.first
    user.access_token = params[:access_token]
    user.save
    if u.count == 0
      nu = AppUser.new
      nu.uid = params[:uid]
      nu.name = params[:name]
      nu.access_token = params[:access_token]
      nu.save
      user = nu
      logger.info "New user: " + nu.uid
    else
      logger.info "Existing user: " + u.first.to_s
      user = u.first
    end
    session[:graph_api] = Koala::Facebook::API.new(user.access_token)
    logger.info "Graph API: " + session[:graph_api].to_s
    render :text => 'success'
  end

  def a2u
    if session[:graph_api] != nil

    end
  end

  def auth

  end

  def auth_persist
    u = AppUser.where(:uid => params[:uid])
    user = u.first
    user.access_token = params[:access_token]
    user.save
    session[:graph_api] = Koala::Facebook::API.new(user.access_token)
    render :text => "success!"
  end

  def test_api
    f_list = ""
    if session[:graph_api] != nil
      @friends = session[:graph_api].get_connections("me", "friends")
      @friends.each { |f|
        logger.info f["name"]
        f_list += f["name"] + "<br>"
      }
      logger.info "called friends"
    else
      logger.info "graph_api not inited"
    end
    render :text => f_list + " yoyoyo"
  end

  def test_user
    a = AppUser.new
    a.uid = rand(100000).to_s
    a.access_token = 'r708whfshafjksd' + rand(99999).to_s
    a.name = 'name_' + rand(9999).to_s
    a.save
    render :text => 'success!'
  end

  def add_user
    a = AppUser.new
    a.uid = params[:uid]
    a.name = params[:name]
    a.access_token = params[:access_token]
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
