class UsersController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  # GET /users
  # GET /users.json
  def index
    @users = User.all
    if @users.nil?
      @success=false
    else
      @success=true
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users/signup
  # returns only success and error
  def signup
    @user = User.new(params.require(:user).permit(:name, :email, :phone, :password))
    if @user.save
      @result={success: true, error: nil}
      # render :show, status: :created, location: @user
    else
      @result={success: false, error: @user.errors}
      # render json: @user.errors, status: :unprocessable_entity
    end
    render json: @result
  end

  # POST /users/login
  #returns success and data
  def login
    @user=User.find_by params[:email]
    if @user.nil?
      @success=false
      @error="Email does not exist"
    else
      if @user.password==params[:password]
        @success=true
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:name, :email, :phone, :password)
  end

end
