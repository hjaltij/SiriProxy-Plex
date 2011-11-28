class PlexSeason
  
  attr_accessor :key, :title, :index
  
  def initialize(key, index, title)
    @key = key
    @index = index.to_i
    @title = title
  end
  
  def to_s
    "#{@title} - #{key} - #{index}"
  end
  
end