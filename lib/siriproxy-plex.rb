# Copyright (C) 2011 by Hjalti Jakobsson <hjalti@hjaltijakobsson.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'cora'
require 'siri_objects'
require 'rexml/document'
require 'plex_library'

#######
# This is a very basic plugin for Plex but I plan on adding to it =)
# Remember to configure the host and port for your Plex Media Server in config.yml in the SiriProxy dir
######

class SiriProxy::Plugin::Plex < SiriProxy::Plugin
  def initialize(config)
    @host = config["plex_host"]
    @port = config["plex_port"]
    @plex_library = PlexLibrary.new(@host, @port)
  end

##
#SKT
##
  listen_for /on deck/i do
    ondeck_shows = all_ondeck()
    say "On Deck shows are #{ondeck_shows}"
    request_completed
  end 
##
#SKT
##

  listen_for /(play|playing) (the)? latest(.+) of(.+)/i do |command, misc, some, show|
    play_latest_episode_of(show)
    request_completed
  end
  
  listen_for /(play|playing)(.+)/i do |command, show_title|

    season_index = 1
    show = @plex_library.find_show(show_title)

    if(@plex_library.has_many_seasons?(show))
      season_index = ask_for_season
      episode_index = ask_for_episode
    else
      episode_index = ask_for_episode
    end
            
    play_episode(show, episode_index, season_index)
    
    request_completed      
  end
  
  listen_for /(play|playing) (.+)\sepisode (.+)/i do |command, first_match, second_match|
    
    show_title = first_match
    
    if(first_match.match(/(.+) season/))
      show_title = $1
    end
    
    show = @plex_library.find_show(show_title)    
    season_index = match_number(first_match, "season")    
    episode_index = match_number(second_match)
    
    #We need to match season in both first match and second
    #play mythbusters episode 9 season 10 or
    #play mythbusters season 10 episode 9
    if(season_index == -1)
      season = match_number(second_match)
    end
    
    has_many_seasons = @plex_library.has_many_seasons?(show)
    
    if(season_index == -1 && has_many_seasons)
      season_index = ask_for_season
    elsif(season_index == -1 && !has_many_seasons)
      season_index = 1
    end
    
    if(show)
      play_episode(show, episode_index, season_index)
    else
      show_not_found
    end
    
    request_completed
  end
  
  def ask_for_number(question)   
    episode = nil
    
    while(response = ask(question))
      
      number = -1
      
      if(response =~ /([0-9]+\s*|one|two|three|four|five|six|seven|eight|nine|ten)/i)
        number = $1
        break
      else
        question = "I didn't get that, please state a number"
      end
    end
    
    if(number.to_i == 0)
        number = map_siri_numbers_to_int(number)
    end
    
    number.to_i
  end
  
  def match_number(text, key = nil)
    if(text.match(/#{key}\s*([0-9]+|one|two|three|four|five|six|seven|eight|nine|ten)/i))
      
      number = $1.to_i
      
      if(number == 0)
        number = map_siri_numbers_to_int($1)
      end
      
      return number
    end
    
    return -1
  end
  
  def ask_for_season
    ask_for_number("Which season?")
  end
  
  def ask_for_episode
    ask_for_number("Which episode?")
  end
  
  def play_episode(show, episode_index, season_index = 1)
    
    if(show != nil)
      episode = @plex_library.find_episode(show, season_index, episode_index)
      
      if(episode)
        @plex_library.play_media(episode.key)
        say "Playing \"#{episode.title}\""
      else
        episode_not_found
      end
    else
      show_not_found
    end
  end
  
  def show_not_found
    say "I'm sorry but I couldn't find that TV show"
  end
  
  def episode_not_found
    say "I'm sorry but I couldn't find the episode you asked for"
  end
  
  def map_siri_numbers_to_int(number)
    ["zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten"].index(number.downcase)
  end
  
  def play_latest_episode_of(show_title)
    show = @plex_library.find_show(show_title)
    
    episode = @plex_library.latest_episode(show)

    if(episode != nil)
      @plex_library.play_media(episode.key)
      say "Playing \"#{episode.title}\""
    else
      episode_not_found
    end
  end
  
end
