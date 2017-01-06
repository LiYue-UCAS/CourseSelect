class AddPreCourseToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :pre_course, :text, default: "尚未编辑"
  end
end
