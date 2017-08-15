class Post
  attr_accessor :title, :body
  attr_reader :id

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS #{self.class.to_s.downcase + "s"} (
        id INTEGER PRIMARY KEY,
        title VARCHAR(255),
        body TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end
  
  def destroy
    sql = <<-SQL
      DELETE FROM posts WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.id)
  end

  def insert
    sql = <<-SQL
      INSERT INTO posts (title, body) VALUES
      (?, ?)
    SQL

    DB[:conn].execute(sql, self.title, self.body)
    results = DB[:conn].execute("SELECT last_insert_rowid() FROM posts;")
    @id = results.flatten.first
  end
  
  def save
   persisted? ? update : insert
  end

  def persisted?
    !!@id
  end

  def self.all
    sql = <<-SQL
      SELECT * FROM posts
    SQL

    results = DB[:conn].execute(sql)

    results.collect{|row| Post.new_from_db(row)}
  end

  def ==(object)
    self.id == object.id
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM posts WHERE id = ? LIMIT 1
    SQL

    results = DB[:conn].execute(sql, id).flatten

    # results = [[1, "Hello", nil]]
    Post.new_from_db(results)
  end

  def self.new_from_db(row)
    self.new.tap do |post|
      post.title = row[1]
      post.body = row[2]
      post.send("id=", row[0])
    end
  end

  def update
    sql = <<-SQL
      UPDATE posts SET title = ?, body = ? WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.title, self.body, self.id) 
  end

  private
    attr_writer :id 
end