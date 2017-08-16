module Persistable
  module ClassMethods

    def self.extended(base)
      base.instance_eval do 
        include Persistable::InstanceMethods

        attr_accessor *self.attribute_names
        attr_reader :id
        private 
          attr_writer :id
      end
    end


    def attribute_names
      # title, body
      self.attributes.keys[1..-1]
    end

    def attributes
      schema_info = DB[:conn].execute("PRAGMA table_info('#{self.table_name}')")

      schema_info.each_with_object({}) do |column_info, attribute_hash|
        attribute_hash[column_info[1]] = column_info[2]
      end
    end

    def table_name
      self.to_s.downcase + "s"
    end

    def attribute_names_for_sql
      attribute_names.join(",")
    end

    def question_marks_for_insert
      ("?" * attribute_names.size).split("").join(",")
    end

    def all
      sql = <<-SQL
        SELECT * FROM #{self.table_name}
      SQL

      results = DB[:conn].execute(sql)

      results.collect{|row| self.new_from_db(row)}
    end

    def find_by_id(id)
      sql = <<-SQL
      SELECT * FROM #{self.table_name} WHERE id = ? LIMIT 1
      SQL

      results = DB[:conn].execute(sql, id).flatten
      self.new_from_db(results)
    end

    def new_from_db(row)
      self.new.tap do |obj|
        self.attributes.keys.each_with_index do |attribute, index|
          obj.send("#{attribute}=", row[index])
        end
      end
    end

    def sql_for_update
      self.attribute_names.collect{|attribute| "#{attribute} = ?"}.join(",")
    end
  end

  module InstanceMethods
    def insert
      sql = <<-SQL
        INSERT INTO #{self.class.table_name} (#{self.class.attribute_names_for_sql}) VALUES
        (#{self.class.question_marks_for_insert})
      SQL

      DB[:conn].execute(sql, *self.attribute_values)
      results = DB[:conn].execute("SELECT last_insert_rowid() FROM #{self.class.table_name};")
      @id = results.flatten.first
    end

    def save
      persisted? ? update : insert
    end

    def update
      sql = <<-SQL
        UPDATE #{self.class.table_name} SET #{self.class.sql_for_update} WHERE id = ?
      SQL

      DB[:conn].execute(sql, *self.attribute_values, self.id) 
    end

    def persisted?
      !!@id
    end

    def ==(object)
      self.id == object.id
    end

    def destroy
      sql = <<-SQL
        DELETE FROM #{self.class.table_name} WHERE id = ?
      SQL
      DB[:conn].execute(sql, self.id)
    end

    def attribute_values
      self.class.attribute_names.collect{|attribute| self.send(attribute)}
    end
  end
end