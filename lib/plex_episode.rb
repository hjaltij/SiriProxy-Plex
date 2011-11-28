class PlexEpisode
  attr_accessor :key, :title, :season_index, :episode_index
  
  def initialize(key, title, season_index, episode_index)
    @key = key
    @title = title
    @season_index = season_index.to_i
    @episode_index = episode_index.to_i
  end
  
  def to_s
    "#{title} - #{season_index} - #{episode_index}"
  end
  
  def <=> other
    if(season_index > other.season_index)
      return 1
    elsif(season_index < other.season_index)
      return -1
    elsif(season_index == other.season_index && episode_index > other.episode_index)
      return 1
    elsif(season_index == other.season_index && episode_index < other.episode_index)
      return -1
    else
      return 0
    end
  end
  
end