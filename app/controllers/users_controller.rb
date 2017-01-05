class UsersController < ApplicationController
  before_action :logged_in, only: :update
  before_action :correct_user, only: [:update, :destroy]

  def new
    @user=User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to root_url, flash: {success: "新账号注册成功,请登陆"}
    else
      flash[:warning] = "账号信息填写有误,请重试"
      render 'new'
    end
  end

  def edit
    @user=User.find_by_id(params[:id])
  end

  def update
    @user = User.find_by_id(params[:id])
    if @user.first == false
      if @user.update_attributes(user_params) && @user.update_attribute("first", true)
        flash={:info => "更新成功"}
      else
        flash={:warning => "更新失败"}
      end
    else
      if @user.update_attributes(user_params)
        flash={:info => "更新成功"}
      else
        flash={:warning => "更新失败"}
      end
    end
    redirect_to root_path, flash: flash
  end

  def destroy
    @user = User.find_by_id(params[:id])
    @user.destroy
    redirect_to users_path(new: false), flash: {success: "用户删除"}
  end




#----------------------------admin start-----------------------------------------------

  def request_index
    @admin = current_user
    @course = Course.find_by_sql("select * from courses where course_state like'processing%'")
    #render plain: params[@course].inspect
  end

  def do_request
    @admin = current_user
    @course = Course.find_by_id(params[:id])
  end

  def do_request_update
    @admin = current_user
    @course = Course.find_by_id(params[:id])
    str = params[:request_type]
    if @course.course_state == "processing_open"
      if str=="agree"
        @course.update_attribute("open",true)
        @course.update_attribute("course_state","agree_open")
        @course.update_attribute("course_code",params[:course_code])
        flash={:info => "已经成功处理请求，同意开课成功"}
      end
      if str=="disagree"
        @course.update_attribute("course_state","disagree_open")
        flash={:info => "已经成功处理请求，不同意开课成功"}
      end
    end

    if @course.course_state == "processing_close"
      if str=="agree"
        @course.update_attribute("open",false)
        @course.update_attribute("course_state","agree_close")
        @course.update_attribute("course_code",params[:code])
        flash={:info => "已经成功处理请求，同意关闭成功"}
      end
      if str=="disagree"
        @course.update_attribute("course_state","disagree_close")
        flash={:info => "已经成功处理请求，不同意关闭成功"}
      end
    end
    redirect_to request_index_users_path, flash: flash
  end

#----------------------------admin end----------------------------------------------------------

#----------------------------------- students function--------------------



  private

  def user_params
    params.require(:user).permit(:name, :email, :major, :department, :password,
                                 :password_confirmation)
  end

  # Confirms a logged-in user.
  def logged_in
    unless logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end

  # Confirms the correct user.
  def correct_user
    @user = User.find(params[:id])
    unless current_user?(@user)
      redirect_to root_url, flash: {:warning => '此操作需要管理员身份'}
    end
  end

  # Confirms a logged-in user.
  def teacher_logged_in
    unless teacher_logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end

end
