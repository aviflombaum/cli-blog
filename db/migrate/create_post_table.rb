class Migration

  def self.table_name
    self.to_s.split("Migration").first.downcase + "s"
  end

  def self.create_table(attributes_hash)
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS #{self.table_name} (
        id INTEGER PRIMARY KEY,
        #{self.sql_for_create(attributes_hash)}
      )
    SQL
    
    DB[:conn].execute(sql)
  end

  def self.sql_for_create(attributes_hash)
    attributes_hash.collect{|k,v| "#{k} #{v}"}.join(",")
  end
end

class PostMigration < Migration
end