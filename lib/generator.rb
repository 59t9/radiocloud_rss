require 'net/http'
require 'uri'
require 'nokogiri'
require './lib/radiocloud'
require './lib/makepodcast'

class GeneratorApp
  include RadioCloud
  def call(env)
    req = Rack::Request.new(env)
    if req.path.rpartition('/')[-1].rpartition('.')[-1].downcase == 'mp3' then
      url = req['tuneid']
      ref = req['refsite']
      if url.nil? or ref.nil? then
        return [404, {}, ["Not Found"]]
      end
      range = req.env['HTTP_RANGE'] # partial content request
      dom, cookie = get_dom_ref(url, ref)
      src = get_tune_src(dom)
      url = 'https:' + src
      adp = cookie['AD-P']
      if src.nil? or adp.nil? then
        return [404, {}, ["Not Found"]]
      end
      Rack::Response.new do |res|
        res.set_cookie('AD-P', cookie['AD-P'])
        res.redirect(url)
      end
#      if req.head? then
#        res = header_cookie(url,adp)
#        #res.each{|k,v|
#        #  p "#{k} : #{v}"
#        #}
#        Rack::Response.new(body=[], status=res.code, header=res)
#      elsif req.get? then
#        res = body_cookie(url,adp,range)
#        #res.each{|k,v|
#        #  p "#{k} : #{v}"
#        #}
#        Rack::Response.new(body=res.body, status=res.code, header=res.header)
#      end
    elsif req.path.rpartition('/')[-1] == 'podcast'
      prg = req['program']
      if prg.nil? then
        return [404, {}, ["Not Found"]]
      end
      url_base = 'https://radiocloud.jp/archive/' + prg + '/'
      dom = get_dom(url_base)
      title = get_title(dom)
      arr_tuneinfo = get_tune_info(dom)
      rss = PodcastRssGenerator.new
      location = req.scheme + '://' + req.host + ':' + req.port.to_s + '/'
      [200, {}, [rss.make(title, location, url_base, arr_tuneinfo)]]
    else
      [404, {}, ["Not Found"]]
    end
  end
end

