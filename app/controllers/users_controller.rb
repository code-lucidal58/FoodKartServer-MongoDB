class UsersController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_user, only: [:update, :delete, :deactivate, :logout, :forgot_password]

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
        validation_check
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
  def login
    @user=User.find_by :email => params[:email]
    if @user.nil?
      @result = {success: false, error: 'Email does not exist'}
    else
      if @user.password == Digest::SHA2.hexdigest(@user.salt + params[:password])
        unless @user.active
          @user.active = true
        end
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
        @result = {success: false, error: 'Password does not match'}
      end
    end
    render json: @result
  end

  #GET /users/logout
  def logout
    if @user.nil?
      @result = {success: false, error: 'Invalid user'}
    else
      @user.access_token = nil
      @user.save
      @result = {success: true}
    end
    render json: @result
  end

  # PATCH /users
  # to update existing records
  def update
    if @user.update(params.require(:user).permit(:name, :email, :address, :phone))
      @result = {success: true,
                 data: {access_token: @user.access_token,
                        id: @user.id.as_json,
                        name: @user.name,
                        email: @user.email,
                        phone: @user.phone,
                        address: @user.address}}
    else
      validation_check
      @result = {success: false, error: @error}
    end
    render json: @result
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

  # POST /users/forgot_password
  def forgot_password
    if @user.nil?
      @result = {success: false, error: 'Invalid user'}
    else
      if @user.password == Digest::SHA2.hexdigest(@user.salt + params[:current_password])
        @user.password = Digest::SHA2.hexdigest(@user.salt + params[:new_password])
        @user.save
        @result ={success: true}
      else
        @result = {success: false, error: 'Password does not match'}
      end
    end
    render json: @result
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find_by access_token: request.headers['HTTP_ACCESS_TOKEN']
  end

  def validation_check
    @email = @user.errors['email'].first
    @phone = @user.errors['phone'].first
    if @email.nil?
      @error = 'Phone number is already taken'
    elsif @phone.nil?
      @error = 'Email Id is already taken'
    else
      @error = 'Phone number and Email Id is already taken'
    end
  end

end
