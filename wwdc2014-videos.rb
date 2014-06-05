require "nokogiri"
require 'open-uri'
require 'httparty'
require 'optparse'

def parse_quality_option
  $quality = :SD
  opt = OptionParser.new
  opt.on('-q Preferred Quality (HD or SD)') { |q|
    $quality = case q.downcase
      when "sd" then :SD
      when "hd" then :HD
    end
  }
  opt.parse!(ARGV)
end

def parse_options
  parse_quality_option
end

def video_url(hash)
  if ($quality == :SD)
    if(hash["SD"])
      return "SD", hash["SD"]
    else
      return nil
    end
  end

  if ($quality == :HD)
    if (hash["HD"])
      return "HD", hash["HD"]
    elsif (hash["SD"])
      return "SD", hash["SD"]
    else
      return nil
    end
  end
end

def file_name_from(session_id, type, title)
  "#{session_id}_#{type.downcase}_#{title.downcase.gsub(/ /, '_').gsub(/\'/, '')}.mov"
end

parse_options

doc = Nokogiri::HTML(open('https://developer.apple.com/videos/wwdc/2014/'))

total_count = doc.css('li.session').length

doc.css('li.session').each_with_index do |session, index|
  title = session.css('li.title').first.child.to_s
  session_id = session['id'].to_i
  download = session.css('p.download').first
  puts "Downloading #{index + 1}/#{total_count} : #{session_id} \"#{title}\""
  if (download)
    links = download.css('a')
    hash = links.each_with_object({}) do |link, hash|
      hash[link.child.to_s] = link['href']
    end

    type, url = video_url(hash)

    file = file_name_from(session_id, type.to_s, title)
    if (File.exists?(file))
      puts "File #{file} already exists. skipping..."
    else
      File.open(file, "wb") do |f|
       f.write HTTParty.get(url).parsed_response
      end
    end
  end
end




