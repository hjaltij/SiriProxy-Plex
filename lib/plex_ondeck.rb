class PlexOndeck
  
  attr_accessor :key, :title, :gptitle
  
  def initialize(key, title, gptitle)
    @key = key
    @title = title
    @gptitle = gptitle
  end
  
  def to_s
    "#{gptitle} - #{@title} - #{key}"
  end
  
end
