require_relative "../config/environment.rb"
require 'pry'

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  attr_reader :id
  attr_accessor :name, :grade

  def initialize (name, grade, id= nil)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade TEXT
      )
      SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE students
      SQL
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql_save = <<-SQL
        INSERT INTO students (name, grade) VALUES (?, ?)
        SQL
      sql_id = <<-SQL
        SELECT last_insert_rowid() FROM students
        SQL
      DB[:conn].execute(sql_save, self.name, self.grade)
      @id = DB[:conn].execute(sql_id)[0][0]
    end
  end

  def update
    sql = <<-SQL
      UPDATE students
      SET name = ?, grade = ?
      WHERE id = ?
      SQL
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

  def self.create(name, grade)
    new_student = self.new(name, grade)
    new_student.save
  end

  def self.new_from_db(row)
    self.new(row[1], row[2], row[0])
  end

  def self.find_by_name(input_name)
    sql = <<-SQL
      SELECT * FROM students WHERE name = ?
    SQL
    array_with_row = DB[:conn].execute(sql, input_name)
    student = Student.new_from_db(array_with_row[0])
    student
  end

end
