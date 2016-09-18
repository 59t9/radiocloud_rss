require 'net/http'
require 'uri'
require 'time'
require 'parallel'
require './lib/radiocloud'

class PodcastRssGenerator
  include RadioCloud
  def initialize
  end

  def episodes_limit
    10
  end
  
  def get_time_length(tuneurl, refsite, defaulttime)
    dom, cookie = get_dom_ref(tuneurl, refsite)
    src = get_tune_src(dom)
    url = 'https:' + src
    adp = cookie['AD-P']
    if src.nil? or adp.nil? then
      return {:time => defaulttime, :length => '0'}
    end
    res = header_cookie(url,adp)
    return {:time => (res['last-modified'] or defaulttime), :length => (res['content-length'] or 0)}
  end
  
  def make(title, location, refsite, arr_tuneinfo)
    urls = []
    Parallel.map(arr_tuneinfo[0...episodes_limit], in_threads: 4) do |filename, caption, time, tuneurl|
      path = filename + '?' + 'tuneid=' + tuneurl + '&amp;' + 'refsite=' + refsite + '&amp;' + 'filename=' + filename
      time_length = get_time_length(tuneurl, refsite, time)
      item = { 'name'   => caption,
        'fname'  => path,
        'time'   => Time.parse(time_length[:time]),
        'length' => time_length[:length]
      }
      urls << item
    end
    
    urls = urls.sort do |a, b|
      a['time'] <=> b['time']
    end
    
    title = title.encode(xml: :text)

    html = <<-EOS
<?xml version="1.0" encoding="utf-8"?>
<rss xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd" version="2.0">
  <channel>
    <title>#{title}</title>
EOS
    
    urls.each do |item|
      url = location.encode(xml: :text) + item['fname'].encode(xml: :text)
      mime = 'audio/mp4'
      
      html += <<-EOS
    <item>
      <title>#{item['name'].encode(xml: :text)}</title>
      <enclosure url="#{url.encode(xml: :text)}"
                 length="#{item['length'].encode(xml: :text)}"
                 type="#{mime.encode(xml: :text)}" />
      <guid isPermaLink="true">#{url.encode(xml: :text)}</guid>
      <pubDate>#{item['time'].rfc822.encode(xml: :text)}</pubDate>
    </item>
    EOS
    end
    
    html += <<-EOS
  </channel>
</rss>
  EOS
  end
end
