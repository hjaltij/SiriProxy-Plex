class PlexOndeck
  
  attr_accessor :key, :title, :gptitle, :viewOffset
  
  def initialize(key, title, gptitle, viewOffset)
    @key = key
    @title = title
    @gptitle = gptitle
	@viewOffset = viewOffset
  end
  
  def to_s
    "#{viewOffset} - #{gptitle} - #{@title} - #{key}"
  end
  
end
