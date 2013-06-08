require 'cgi'
require 'open-uri'
require 'plex_show'
require 'plex_season'
require 'plex_episode'
require 'plex_ondeck'
TV = "com.plexapp.agents.thetvdb"
MOVIES = "com.plexapp.agents.imdb"


class PlexLibrary
  def initialize(host, port, tv_index, movie_index, player = nil)
    @host     = host
    @port     = port
#    @tv_index = tv_index
    @movie_index = movie_index
    @player   = player.nil? ? host : player
    @indexes = {}
    @indexes["#{TV}"] = []
    if (tv_index == "auto")
       doc = xml_doc_for_path("/library/sections")
       doc.elements.each('MediaContainer/Directory') do |ele|
          num = ele.attribute("key").value
          agent = ele.attribute("agent").value
          if (!@indexes.include?("#{agent}"))
             @indexes["#{agent}"] = []
          end
             @indexes["#{agent}"] << "#{num}"
       end
    else
       @indexes["#{TV}"] << "#{tv_index}"
    end
	@indexes["#{MOVIES}"] = []
	@indexes["#{MOVIES}"] << "#{movie_index}"
  end
  
  def base_path
    "http://#{@host}:#{@port}"
  end
  
  def xml_doc_for_path(path)
    uri = "#{base_path}#{path}"
    xml_data = open(uri).read
    doc = REXML::Document.new(xml_data)
  end
  
# all_shows and all_ondeck should be colapsed into one method with a variable for path.

  def all_shows
    shows = []
    @indexes[TV].each do |tvindex|
       doc = xml_doc_for_path("/library/sections/#{tvindex}/all")

       doc.elements.each('MediaContainer/Directory') do |ele|
         shows << PlexShow.new(ele.attribute("key").value, ele.attribute("title").value)
       end
    end
    return shows
  end

  def all_ondeck
    ondeck_shows = []
    @indexes[TV].each do |tvindex|
       doc = xml_doc_for_path("/library/sections/#{tvindex}/onDeck")

       doc.elements.each('MediaContainer/Video') do |ele|
         ondeck_shows << PlexOndeck.new(ele.attribute("key").value, ele.attribute("title").value, ele.attribute("grandparentTitle").value)
       end
    end
    return ondeck_shows
  end

  def show_seasons(show)
    
    if(show.key != nil)
      uri = "http://#{@host}:#{@port}#{show.key}"
      
      xml_data = open(uri).read
      doc = REXML::Document.new(xml_data)
      seasons = []
      
      doc.elements.each('MediaContainer/Directory') do |ele|
        if(ele.attribute("key").value !~ /allLeaves/)
          seasons << PlexSeason.new(ele.attribute("key").value, ele.attribute("title").value, ele.attribute("index").value)
        end
      end
      
      return seasons
    end
    
  end
  
  def show_episodes(show)
    if(show != nil && show.key != nil)
      doc = xml_doc_for_path(show.key)
      episodes = []
      
      key = nil
      
      doc.elements.each('MediaContainer/Directory') do |ele|
        if(ele.attribute("key").value =~ /allLeaves/)
          key = ele.attribute("key")
        end
      end
      
      if(key == nil && doc.elements.size > 0)
        doc.elements.each('MediaContainer/Directory') do |ele|
          key = ele.attribute("key")
        end
      end
      
      episodes_doc = xml_doc_for_path(key)
      
      episodes_doc.elements.each('MediaContainer/Video') do |video_element|
        parentIndex = video_element.attribute("parentIndex") ? video_element.attribute("parentIndex").value : 1
        episodes << PlexEpisode.new(video_element.attribute("key").value, video_element.attribute("title").value, parentIndex, video_element.attribute("index").value)
      end
      
      return episodes
    end
  end

  def find_ondeck_show(title)
    title.gsub!(/^The\s+/, "")
    splitted = title.split(" ").join("|")
    shows = all_ondeck
    show = shows.detect {|s| s.gptitle.match(/#{splitted}/i)}
    return show
  end
  
  def find_show(title)
    title.gsub!(/^The\s+/, "")
    splitted = title.split(" ").join("|") 
    shows = all_shows    
    shows.detect {|s| s.title.match(/#{splitted}/i)}
  end
  
  def find_episode(show, season_index, episode_index)
    if(show != nil)
      episodes = show_episodes(show)
      episodes.find {|e| e.episode_index == episode_index && e.season_index == season_index}
    end
  end
  
  def has_many_seasons?(show)
    if(show == nil)
      return false
    end
    
    episodes = show_episodes(show)    
    season = nil
    
    episodes.each do |ep|
      if(season != nil && season != ep.season_index)
        return true
      end
      
      season = ep.season_index
    end
    
    return false
  end
  
  def latest_season_index(show)
    if show == nil then return nil end
    show_episodes(show).sort.last.season_index
  end
  
  def latest_episode(show)
    if show == nil then return nil end
    show_episodes(show).sort.last
  end
  
    def all_movies
    movies = []
	@indexes[MOVIES].each do |movieindex|
       doc = xml_doc_for_path("/library/sections/#{movieindex}/all")

       doc.elements.each('MediaContainer/Video') do |ele|
         movies << PlexShow.new(ele.attribute("key").value, ele.attribute("title").value)
       end
    end
    return movies
  end
  
  def find_movie(title)
    title.gsub!(/^The\s+/, "")
    splitted = title.split(" ").join("|") 
    movies = all_movies    
    movies.detect {|s| s.title.match(/#{splitted}/i)}
  end

  def all_ondeck_movies
    ondeck_movies = []
	@indexes[MOVIES].each do |movieindex|
       doc = xml_doc_for_path("/library/sections/#{movieindex}/onDeck")

       doc.elements.each('MediaContainer/Video') do |ele|
         ondeck_movies << PlexOndeck.new(ele.attribute("key").value, ele.attribute("title").value, ele.attribute("grandparentTitle"))
       end
    end
    return ondeck_movies
  end
  
  def find_ondeck_movie(title)
    title.gsub!(/^The\s+/, "")
    splitted = title.split(" ").join("|")
    movies = all_ondeck_movies
    movies = movies.detect {|s| s.title.match(/#{splitted}/i)}
    return movies
  end
  
  def play_media(key)
    url_encoded_key = CGI::escape(key)
    uri = "http://#{@host}:#{@port}/system/players/#{@player}/application/playMedia?key=#{url_encoded_key}&path=http://#{@host}:#{@port}#{key}"
    
    begin
      open(uri).read
    rescue OpenURI::HTTPError => err
      puts "Cannot start playback on #{@player} - are you sure the Plex Player is running (#{err}) -> #{uri}"
    end
  end
  
  def pause
    uri = "http://#{@host}:#{@port}/system/players/#{@player}/playback/pause"
	
    begin
      open(uri).read
    rescue OpenURI::HTTPError => err
      puts "Cannot pause playback on #{@player} - are you sure the Plex Player is running (#{err}) -> #{uri}"
    end
  end
  
  def resume_play
    uri = "http://#{@host}:#{@port}/system/players/#{@player}/playback/play"

    begin
      open(uri).read
    rescue OpenURI::HTTPError => err
      puts "Cannot resume playback on #{@player} - are you sure the Plex Player is running (#{err}) -> #{uri}"
    end
  end
  
  def stop
    uri = "http://#{@host}:#{@port}/system/players/#{@player}/playback/stop"
	
    begin
      open(uri).read
    rescue OpenURI::HTTPError => err
      puts "Cannot stop playback on #{@player} - are you sure the Plex Player is running (#{err}) -> #{uri}"
    end
  end
  
end
