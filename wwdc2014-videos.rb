require "nokogiri"
require 'open-uri'
require 'httparty'

def best_video_url(hash)
  if (hash["HD"]) then
    return "HD", hash["HD"]
  elsif (hash["SD"]) then
    return "SD", hash["SD"]
  else
    return nil
  end
end

def file_name_from(session_id, type, title)
  "#{session_id}_#{type.to_s.downcase}_#{title.downcase.gsub(/ /, '_')}.mov"
end

doc = Nokogiri::HTML(open('https://developer.apple.com/videos/wwdc/2014/'))
doc.css('li.session').each do |session|
  title = session.css('li.title').first.child.to_s
  session_id = session['id'].to_i
  download = session.css('p.download').first
  puts "Downloading Session #{session_id} \"#{title}\""
  if (download)
    links = download.css('a')
    hash = links.each_with_object({}) do |link, hash|
      hash[link.child.to_s] = link['href']
    end

    type, url = best_video_url(hash)

    file = file_name_from(session_id, type, title)
    if (File.exists?(file))
      puts "File #{file} already exists. skipping..."
    else
      File.open(file, "wb") do |f|
       f.write HTTParty.get(url).parsed_response
      end
    end
  end
end




