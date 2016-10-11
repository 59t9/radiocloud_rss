require 'net/http'
require 'uri'
require 'nokogiri'

module RadioCloud

  def get_dom(url)
    res = Net::HTTP.get(URI(url))
    return  Nokogiri::HTML.parse(res)
  end
  
  def get_title(dom)
    dom.xpath('//div[@id="left"]//div[@class="program_info"]/h2').inner_text.strip
  end
  
  def get_tune_info(dom)
    dom.xpath('//div[@id="contents_open"]//li[@class="contents_box"]').map do |node|
      time = node.xpath('dl/dt').inner_text.strip + ' 00:00:00 +0900'
      day = time.gsub(/\./ , '_')
      day2 = time
      caption = day2 + ' ' +node.xpath('dl/dd/span').inner_text.strip
      tuneurl = url = 'https:' + node.xpath('input[@name="file_url"]/@value').inner_text + '/'
      filename = node.xpath('input[@name="content_id"]/@value').inner_text + '.m4a'
      [filename, caption, time, tuneurl]
    end
  end
  
  def get_dom_ref(url, ref)
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.start()
    res, = http.get(uri.path, 'Referer' => ref)
    cookie = {}
    res.get_fields('Set-Cookie').each{|str|
      k,v = str[0...str.index(';')].split('=')
      cookie[k] = v
    }
    http.finish()
    return [ Nokogiri::HTML.parse(res.body), cookie ]
  end
  
  def get_tune_src(dom)
    scr_txt = dom.xpath('//div[@id="content"]/script[@type="text/javascript"]').inner_text
    if %r|^.*var source = "(.*)".*$| =~ scr_txt
      $1
    else
      ""
    end
  end
  
  def header_cookie(url, adp)
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
#    http.set_debug_output $stderr
    http.start()
    req = Net::HTTP::Head.new uri
    req['Cookie'] = "AD-P=#{adp}"
    res = http.request(req)
    http.finish()
    return res
  end
  
  def body_cookie(url, adp,range)
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
#    http.set_debug_output $stderr
    http.start()
    req = Net::HTTP::Get.new uri
    req['Cookie'] = "AD-P=#{adp}"
    if ! range.nil? then
      req['Range'] = range
    end
    res = http.request(req)
    http.finish()
    return res
  end

def header_ref_cookie(url, ref, adp)
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
#    http.set_debug_output $stderr
    http.start()
    req = Net::HTTP::Head.new uri
    req['Cookie'] = "AD-P=#{adp}"
    req['Referer'] = ref
    res = http.request(req)
    http.finish()
    return res
  end
  
  def body_ref_cookie(url, ref, adp, range)
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
#    http.set_debug_output $stderr
    http.start()
    req = Net::HTTP::Get.new uri
    req['Cookie'] = "AD-P=#{adp}"
    req['Referer'] = ref
    if ! range.nil? then
      req['Range'] = range
    end
    res = http.request(req)
    http.finish()
    return res
  end

end
