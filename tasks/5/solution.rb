# => Not enough time :(
# => To-do: write solution
class DataModel
  def initialize(attrs = {})
  end

  def save
  end

  def delete
  end

  class << self
    def data_store(storage)
    end

    def attributes(*attrs)
      hash = {}
      attrs.each do |attribute|
        define_method "#{attribute}=" do |arg|
          hash[attribute] = arg
        end
        define_method attribute do
          hash[attribute]
        end
      end
      hash
    end

    def where
    end
  end
end

class ArrayStore
  attr_accessor :id
  attr_reader :storage

  def initialize
    @id
    @storage = []
  end

  def create
  end

  def find
  end

  def update
  end

  def delete
  end
end
class HashStore
  attr_accessor :id
  attr_reader :storage

  def initialize
    @id
    @storage = {}
  end

  def create
  end

  def find
  end

  def update
  end

  def delete
  end
end
