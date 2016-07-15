require 'net/http'
require 'uri'
require 'time'
require './lib/radiocloud'

class PodcastRssGenerator
  include RadioCloud
  def initialize
  end
  
  def make(title, arr_tuneinfo)
    location = "http://59t9.mydns.jp:8000/"
    
    urls = arr_tuneinfo.map do |filename, caption, time, tuneurl, refsite|
      path = filename + '?' + 'tuneid=' + tuneurl + '&amp;' + 'refsite=' + refsite + '&amp;' + 'filename=' + filename
      { 'name'   => caption,
        'fname'  => path,
        'time'   => Time.parse(time),
        'length' => '0' # tentative, but not available by iTunes
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
