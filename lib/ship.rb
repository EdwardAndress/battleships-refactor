class Ship
    attr_accessor :size
    attr_accessor :coords
  
    def initialize(size)
      @size = size
      @hp = size
      @coords = []
    end
  
    def damage
      @hp -= 1
    end
  
    def isDead
      return @hp == 0
    end
  end