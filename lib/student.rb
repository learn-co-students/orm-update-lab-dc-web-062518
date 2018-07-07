require_relative "../config/environment.rb"
require 'pry'
class Student
  @@all = []
  attr_accessor :name, :grade, :id

  def initialize(id=nil, name, grade)
    @id = id
    @name = name
    @grade = grade
    @@all << self
  end

  def self.create_table
    sql= "CREATE TABLE students(id INTEGER PRIMARY KEY, name TEXT, grade INTEGER);"
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql= "DROP TABLE students"
    DB[:conn].execute(sql)
  end

  def save
    if self.id
        self.update
    else
      sql = "INSERT INTO students(name, grade) VALUES (?, ?)"
      DB[:conn].execute(sql, @name, @grade)
      sql = "SELECT last_insert_rowid() FROM students"
      @id = DB[:conn].execute(sql)[0][0]
    end
  end

  def self.create(name, grade)
    student = Student.new(name, grade)
    student.save
  end

  def self.new_from_db(row)
    Student.new(row[0], row[1], row[2])
  end

  def self.find_by_name(name)
    array = nil
    sql = "SELECT * FROM students WHERE name = ?"
    arr = DB[:conn].execute(sql, name)
    @@all.each {|students|
      if students.name == arr[0][1]
      array = students
      end
    }
    array
  end

  def update
    sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

end
