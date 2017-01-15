# => 1. Изключително важно е комплексен проблем да се разбива на по-малки атомарни части!
# => 2. Добра практика е да се изнасят класовите методи като модул.
class DataModel
  class DeleteUnsavedRecordError < StandardError
  end

  class UnknownAttributeError < StandardError
    def initialize(attribute)
      super "Unknown attribute #{attribute}"
    end
  end

  def initialize(attributes = {})
    @store = self.class.data_store
    @attributes = attributes.select { |key, _| self.class.attributes.include? key }
  end

  def save
    if id
      @store.update(id, @attributes)
    else
      self.id = @store.next_id
      @store.create(@attributes)
    end
    self
  end

  def delete
    raise DeleteUnsavedRecordError.new unless id
    @store.delete(id: id)
  end

  def ==(other)
    return id == other.id if id && other.id
    equal? other
  end

  class << self
    def data_store(store = nil)
      return @data_store unless store
      @data_store = store
    end

    def attributes(*attributes)
      return @attributes if attributes.empty?
      @attributes = attributes + [:id]
      define_methods
    end

    def where(query)
      query.keys.reject { |key| @attributes.include? key }.each do |key|
        raise DataModel::UnknownAttributeError.new(key)
      end
      data_store.find(query)
                .map { |record| new(record) }
    end

    def define_methods
      @attributes.each do |attribute|
        define_method("#{attribute}=") { |value| @attributes[attribute] = value }
        define_method(attribute) { @attributes[attribute] }
        define_singleton_method("find_by_#{attribute}") do |value|
          where(attribute => value)
        end
      end
    end
  end
end

class ArrayStore
  attr_reader :storage

  def initialize
    @storage = []
    @id = 0
  end

  def next_id
    @id += 1
  end

  def create(record)
    @storage << record
  end

  def find(query)
    @storage.select { |record| match_record? query, record }
  end

  def delete(query)
    @storage.reject! { |record| match_record? query, record }
  end

  def update(id, record)
    index = @storage.find_index { |record| record[:id] == id }
    return unless index

    @storage[index] = record
  end

  # => Refactor:
  private

  def match_record?(query, record)
    query.all? { |key, value| record[key] == value }
  end
end

class HashStore
  attr_reader :storage

  def initialize
    @id = 0
    @storage = {}
  end

  def next_id
    @id += 1
  end

  def create(attributes)
    @storage[attributes[:id]] = attributes
  end

  def find(query)
    @storage.values.select do |record|
      match_record? query, record
    end
  end

  def update(id, attributes)
    return unless @storage.key? id
    @storage[id] = attributes
  end

  def delete(attributes)
    find(attributes).each { |record| @storage.delete(record[:id]) }
  end

  private

  def match_record?(query, record)
    query.all? { |key, value| record[key] == value }
  end
end
