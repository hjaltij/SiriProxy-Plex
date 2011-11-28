class PlexShow
  
  attr_accessor :key, :title
  
  def initialize(key, title)
    @key = key
    @title = title
  end
  
  def to_s
    "#{@title} - #{key}"
  end
  
end