class AddTeacherInfoCourses < ActiveRecord::Migration
  def change
    add_column :courses, :teacher_info, :text, default: "尚未编辑"
  end
end
