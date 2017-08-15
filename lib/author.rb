class Author
    ATTRIBUTES = {
      :id => "INTEGER PRIMARY KEY",
      :name => "VARCHAR(255)"      
    }

    ATTRIBUTES.keys.each do |attribute_name|
      attr_accessor attribute_name
    end

    def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS #{self.class.to_s.downcase + "s"} (
        #{
          ATTRIBUTES.collect{|k, v| "#{k} #{v}"}.join(",")}         
      )"
    SQL
    DB[:conn].execute(sql)
  end

end