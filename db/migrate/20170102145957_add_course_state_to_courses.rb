class AddCourseStateToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :course_state, :string, default: "已通过"
  end
end
