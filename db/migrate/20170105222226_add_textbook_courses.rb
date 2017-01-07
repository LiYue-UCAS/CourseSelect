class AddTextbookCourses < ActiveRecord::Migration
  def change
    add_column :courses, :textbook, :text, default: "尚未编辑"
  end
end
