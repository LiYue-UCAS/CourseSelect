class AddCoursePurposeToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :course_purpose, :text, default: "尚未编辑"
  end
end
