class Dog

  attr_accessor :name, :breed, :id

  def initialize(attributes_hash)
    # binding.pry
    @name = attributes_hash[:name]
    @breed = attributes_hash[:breed]
    attributes_hash[:id] ? @id = attributes_hash[:id] : @id = nil
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    );
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE dogs
    SQL
    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
    INSERT INTO dogs (name, breed)
    VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    # binding.pry
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(attributes_hash)
    dog = self.new(attributes_hash)
    dog.save
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE id = ?
    SQL
    dog_data = DB[:conn].execute(sql, id)[0]
    dog = Dog.new_from_db(dog_data)
  end

  def self.find_or_create_by(attributes_hash)
    dog = DB[:conn].execute("SELECT *  FROM dogs WHERE name = ? AND breed = ?;", attributes_hash[:name], attributes_hash[:breed])
    if !dog.empty?
      dog_data = dog[0]
      dog = self.new_from_db(dog_data)
    else
      dog = self.create(attributes_hash)
    end
    dog
  end

  def self.new_from_db(row)
    # binding.pry
    new_dog = Dog.new({id: row[0], name: row[1], breed: row[2]})
    # new_dog = Dog.new(row_hash)
    new_dog
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE name = ?
    SQL
    dog_data = DB[:conn].execute(sql, name)[0]
    dog = Dog.new_from_db(dog_data)
    dog
  end

  def update
    sql = <<-SQL
    UPDATE dogs
    SET name = ?
    WHERE id = ?
    SQL
    DB[:conn].execute(sql, name, self.id)
  end

end
