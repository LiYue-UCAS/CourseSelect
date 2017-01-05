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

  def changepass
    @user = User.find_by_id(params[:id])
  end

  def submitpass
    user = User.find_by_email(params[:session][:email])
    log_in (user)
      if user.update_attribute('password',params[:session][:password])
        flash={:info => "更改成功"}
      else
        flash={:warning => "更改失败"}
      end
    @user = User.find_by_name('彭兆卿')
    log_in(@user)
    redirect_to root_path, flash: flash
  end



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

  def admin_logged_in
    unless admin_logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end
end
