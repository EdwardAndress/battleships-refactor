class Ship
    attr_accessor :size, :coords
  
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