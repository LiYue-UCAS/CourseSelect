class CoursesController < ApplicationController

  before_action :student_logged_in, only: [:select, :quit, :list]
  before_action :teacher_logged_in, only: [:new, :create, :edit, :destroy, :update]
  before_action :logged_in, only: :index

  #-------------------------for teachers----------------------

  def new
    @course=Course.new
  end

  def create
    @course = Course.new(course_params)
    @course.course_state = "processing_open"
    if @course.save
      current_user.teaching_courses<<@course
      redirect_to courses_path, flash: {success: "新课程申请提交成功，请等候管理员处理"}
    else
      flash[:warning] = "信息填写有误,请重试"
      render 'new'
    end
  end

  def edit
    @course=Course.find_by_id(params[:id])
  end

  def update
    @course = Course.find_by_id(params[:id])


    if @course.update_attributes(course_params)
      flash={:info => "更新成功,申请已经提交管理员处理"}
    else
      flash={:warning => "更新失败"}
    end
    redirect_to courses_path, flash: flash
  end

  def destroy
    @course=Course.find_by_id(params[:id])
    current_user.teaching_courses.delete(@course)
    @course.destroy
    flash={:success => "成功删除课程: #{@course.name}"}
    redirect_to courses_path, flash: flash
  end

  def open
    @course = Course.find_by_id(params[:id])
    #@course.update_attribute("open", true)
    @course.update_attribute("course_state","processing_open")
    redirect_to courses_path, flash: {:success => "已成功将该开课申请提交到管理员处理"}
  end

  def close
    @course = Course.find_by_id(params[:id])
    @course.update_attribute("course_state","processing_close")
    redirect_to courses_path, flash: {:success => "已成功将该关课申请提交到管理员处理"}
  end

  #-------------------------for students----------------------

  def list
    @course=Course.all
    #@course = Course.paginate(:page=>params[:page],:per_page=>8)

    @course=@course-current_user.courses
    @course_open = Array.new # 定义数组类变量, []
    @course.each do |course| # 循环数组
      if(course.open == true && course.course_state == "agree_open")
        @course_open<< course #追加，写进数组
      end
    end
    @course = @course_open


    #------------分页---------------------
    total = @course.count
    params[:total] = total
    if params[:page] == nil
      params[:page] = 1  #进行初始化
    end
    if total % $PageSize == 0
      params[:pageNum] = total / $PageSize
    else
      params[:pageNum] = total / $PageSize + 1
    end

    #计算分页的开始和结束位置
    params[:pageStart] = (params[:page].to_i - 1) * $PageSize

    if params[:pageStart].to_i + $PageSize <= params[:total].to_i
      params[:pageEnd] = params[:pageStart].to_i + $PageSize - 1
    else
      params[:pageEnd] = params[:total].to_i - 1  #最后一页
    end
    #---------------------------------------------------------------------
    end


  #学生选课
  def select
    @course=Course.find_by_id(params[:id])#查找
    course_weeks_new = @course.course_week.split("-")
    start_week_new = course_weeks_new[0].to_i
    end_week_new = course_weeks_new[1].to_i
    flag = false
    course_time_new = @course.course_week.split("-")  #周几-几-几-几节课

    current_user.courses.each do |course|
      course_weeks = course.course_week.split("-")
      start_week = course_weeks[0].to_i
      end_week = course_weeks[1].to_i
      course_time = course.course_week.split("-")  #周几-几-几-几节课

      for i in 1..course_time_new.length
        for j in 1..course_time.length
          if (course_time_new[0]==course_time[0] && course_time_new[i]==course_time[j])
            if(!((start_week > end_week_new) || (end_week < start_week_new)))
              flag =true
            end
          end
        end
      end
    end

    if(!flag)
      current_user.courses<<@course
      student_num = @course.student_num + 1
      if @course.update_attribute("student_num",student_num)
        flash={:success => "成功选择课程: #{@course.name}"}
      else
        flash={:success => "失败选择课程: #{@course.name}"}
      end
    else
      flash={:success => "冲突选择课程: #{@course.name}"}
    end

    redirect_to courses_path, flash: flash
  end

  def quit
    @course=Course.find_by_id(params[:id])
    current_user.courses.delete(@course)
    student_num = @course.student_num - 1
    if @course.update_attribute("student_num",student_num)
      flash={:success => "成功退选课程: #{@course.name}"}
    else
      flash={:success => "失败退选课程: #{@course.name}"}
    end
    redirect_to courses_path, flash: flash #跳到下一个页面
  end


  def sousuo
    #获取想要查询的字符串
    @course_search = params["course_search"]
    @search_type = params["search_type"]

    #生成数据表字段名
    if @search_type == "课程名称"
        search_colum = "name"
      elsif @search_type == "课程编号"
        search_colum = "course_code"
      elsif @search_type == "课程类型"
        search_colum = "course_type"
      elsif @search_type == "课程学分"
        search_colum = "credit"
      elsif @search_type == "上课周数"
        search_colum = "course_week"
      elsif @search_type == "上课时间"
        search_colum = "course_time"
      elsif @search_type == "考试类型"
        search_colum = "exam_type"
      else
        search_colum = "name"
      end

    #防止sql注入，生成sql语句
    sql = "%"+@course_search+"%" #% ：表示任意0个或多个字符。可匹配任意类型和长度的字符
                              #有些情况下若是中文，请使用两个百分号（%%）表示

    @course = Course.find_by_sql("select * from courses where #{search_colum} like '#{sql}'")

  end



  def show
    @course=Course.find_by_id(params[:id])
  end



  #-------------------------for both teachers and students----------------------

  def index
    if teacher_logged_in?
    @course=current_user.teaching_courses.paginate(:page=>params[:page],:per_page=>5)

    end
    if student_logged_in?
    @course=current_user.courses.paginate(:page=>params[:page],:per_page=>5)
    @courses = current_user.courses
    @sum_time = 0
    @sum_credit = 0
    @courses.each do |courses|
     @sum_credit += courses.credit[3...4].to_i
      @sum_time += courses.credit[0...1].to_i
    end
    end
  end

  def create_course_code
    @course = Course.find_by_id(params[:id])
  end

  private

  # Confirms a student logged-in user.
  def student_logged_in
    unless student_logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end

  # Confirms a teacher logged-in user.
  def teacher_logged_in
    unless teacher_logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end

  # Confirms a  logged-in user.
  def logged_in
    unless logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end

  def course_params
    params.require(:course).permit(:course_code, :name, :course_type, :teaching_type, :exam_type,
                                   :credit, :limit_num, :class_room, :course_time, :course_week)
  end

  end