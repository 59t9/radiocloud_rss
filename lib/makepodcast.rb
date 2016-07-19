require 'net/http'
require 'uri'
require 'time'
require './lib/radiocloud'

class PodcastRssGenerator
  include RadioCloud
  def initialize
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
    return {:time => res['last-modified'], :length => res['content-length']}
  end
  
  def make(title, location, refsite, arr_tuneinfo)
    
    urls = arr_tuneinfo.map do |filename, caption, time, tuneurl|
      path = filename + '?' + 'tuneid=' + tuneurl + '&amp;' + 'refsite=' + refsite + '&amp;' + 'filename=' + filename
      time_length = get_time_length(tuneurl, refsite, time)
      { 'name'   => caption,
        'fname'  => path,
        'time'   => Time.parse(time_length[:time]),
        'length' => time_length[:length]
      }
    end
    
    urls = urls.sort do |a, b|
      a['time'] <=> b['time']
    end
    
    html = <<-EOS
<?xml version="1.0" encoding="utf-8"?>
<rss xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd" version="2.0">
  <channel>
    <title>#{title}</title>
EOS
    
    urls.each do |item|
      url = location + item['fname']
      mime = 'audio/mp3'
      
      html += <<-EOS
    <item>
      <title>#{item['name']}</title>
      <enclosure url="#{url}"
                 length="#{item['length']}"
                 type="#{mime}" />
      <guid isPermaLink="true">#{url}</guid>
      <pubDate>#{item['time'].rfc822}</pubDate>
    </item>
    EOS
    end
    
    html += <<-EOS
  </channel>
</rss>
  EOS
  end
end
