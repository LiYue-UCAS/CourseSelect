class AddCourseInfoCourses < ActiveRecord::Migration
  def change
    add_column :courses, :course_info, :text, default: "尚未编辑"
  end
end
