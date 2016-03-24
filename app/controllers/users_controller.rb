class UsersController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_user, only: [:update, :delete, :deactivate]

  # GET /users
  # show only those records which are active
  def index
    @users = User.where :active => true
    if @users.size == 0
      @success = false
    else
      @success = true
    end
  end

  # GET /users/all
  # shows all record irrespective of its being active
  # made for debugging purpose
  def all
    @users = User.all
    @success = true
    render action: :index
  end

  # GET /users/1
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
  # to create new users
  def signup
    @user = User.new(params.require(:user).permit(:name, :email, :phone, :address, :password))
    if @user.save
      salt = BCrypt::Engine.generate_salt
      @user.salt=salt
      @user.password = Digest::SHA2.hexdigest(salt + @user.password)
      @user.access_token = Digest::SHA1.hexdigest([Time.now, rand].join)
      @user.save
      @result = {success: true,
                 data: {access_token: @user.access_token,
                        id: @user.id.as_json,
                        name: @user.name,
                        email: @user.email,
                        phone: @user.phone,
                        address: @user.address}}
    else
      @exist_user = User.any_of({email: @user.email}, {phone: @user.phone}).first
      if @exist_user.active
        @email = @user.errors['email'].first
        @phone = @user.errors['phone'].first
        if @email.nil?
          @error = 'Phone number is already taken'
        elsif @phone.nil?
          @error = 'Email Id is already taken'
        else
          @error = 'Phone number and Email Id is already taken'
        end
      else
        @error = 'Account exists.. Want to make it live?'
      end
      @result = {success: false, error: @error}
    end
    # this line automatically converts @result to json. No need for additional .json.jbuilder in views folder.
    #that file is used to introduce additional formatting like applying conditions or forming nested json objects
    render json: @result
  end

  # POST /users/login
  #returns success and data
  def login
    @user=User.find_by :email => params[:email], :active => true
    if @user.nil?
      @success = false
      @error = "Email does not exist"
    else
      if @user.password == Digest::SHA2.hexdigest(@user.salt + params[:password])
        @success=true
      else
        @success= false
        @error = "Password does not match"
      end
    end
    render json: @user
  end

  # PATCH /users
  # to update existing records
  def update
    respond_to do |format|
      if @user.update(params.require(:user).permit(:name, :email, :address, :phone))
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users
  # to deactivate an account
  def deactivate
    if @user.nil?
      @result={:success => false, :error => "User does not exist"}
    else
      @user.active=false
      @user.save
      @result={:success => true}
    end
    render json: @result
  end

  # DELETE /users/delete
  # to complete delete a record from database
  def delete
    @user.destroy
    render json: {success: true}
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find_by access_token: request.headers['HTTP_ACCESS_TOKEN']
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:name, :email, :address, :phone, :password)
  end

end
