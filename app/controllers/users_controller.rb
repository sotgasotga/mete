class UsersController < ApplicationController
  include ApplicationHelper
  
  # GET /users
  def index
    @users = User.order(active: :desc).order("name COLLATE nocase")
    # index.html.haml
  end

  # GET /users/1
  def show
    @user = User.find(params[:id])
    @drinks = Drink.order("name COLLATE nocase").where(active: true).where("price < ?", @user.balance + 50)
    # show.html.haml
  end

  # GET /users/1/transaction
  # GET /users/1/transaction.json
  def transaction
    @users = User.order(active: :desc).order("name COLLATE nocase")
    @user = User.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/1/transaction/2
  # GET /users/1/transaction/2.json
  def transaction_amount
    @user = User.find(params[:id])
    @target = User.find(params[:to_id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  # PATCH /users/1/transaction/2
  # PATCH /users/1/transaction/2.json
  def transaction_patch
    @user = User.find(params[:id])
    @target = User.find(params[:to_id])
    @user.payment(BigDecimal.new(params[:amount]))
    @target.deposit(BigDecimal.new(params[:amount]))
    flash[:success] = "You just transfered some money to #{@target.name} and your new balance is #{@user.balance}."
    warn_user_if_audit
    redirect_to request.referrer
  end

  # GET /users/new
  def new
    @user = User.new
    # new.html.haml
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
    # edit.html.haml
  end

  # POST /users
  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to @user, success: 'User was successfully created.'
    else
      render action: "new", error: "Couldn't create the user. Error: #{@user.errors} Status: #{:unprocessable_entity}"
    end
  end

  # PATCH /users/1
  def update
    @user = User.find(params[:id])
    @old_audit_status = @user.audit
    if @user.update_attributes(user_params)
      if @user.audit != @old_audit_status
        unless @user.audit
          @user_audits = Audit.where(:user => @user.id)
          @user_audits.each do |audit|
            audit.user = nil
            audit.save!
          end
          flash[:notice] = "Deleted all your logs."
        end
      end
      flash[:success] = "User was successfully updated."
      no_resp_redir @user
    else
      render action: "edit", error: "Couldn't update the user. Error: #{@user.errors} Status: #{:unprocessable_entity}"
    end
  end

  # DELETE /users/1
  def destroy
    @user = User.find(params[:id])
    Audit.create! bank_difference: -@user.balance, difference: 0, drink: 0, user:@user.id
    if @user.destroy
      flash[:success] = "User was successfully deleted."
      no_resp_redir users_url
    else
      redirect_to users_url, error:  "Couldn't delete the user. Error: #{@user.errors} Status: #{:unprocessable_entity}"
    end
  end

# GET /users/1/deposit
# GET /users/1/deposit.json
def deposit
    @user = User.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

# GET /users/1/retrieve
# GET /users/1/retrieve.json
def retrieve
    @user = User.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
end

  # PATCH /users/1/deposit?amount=100
  # PATCH /users/1/deposit.json?amount=100
  def deposit_patch
    @user = User.find(params[:id])
    @user.deposit(BigDecimal.new(params[:amount]))
    flash[:success] = "You just deposited some money and your new balance is #{show_amount(@user.balance)}. Thank you."
    warn_user_if_audit
    redirect_to request.referrer
  end

  # PATCH /users/1/retrieve?amount=100
  # PATCH /users/1/retrieve.json?amount=100
  def retrieve_patch
    @user = User.find(params[:id])
    @user.payment(BigDecimal.new(params[:amount]))
    flash[:success] = "You just retrieved some money and your new balance is #{@user.balance}. Thank you."
    warn_user_if_audit
    redirect_to request.referrer
  end

  # GET /users/1/buy?drink=5
  def buy
    @user = User.find(params[:id])
    @drink = Drink.find(params[:drink])
    buy_drink params[:bar] == "true"
  end
  
  # POST /users/1/buy_barcode
  def buy_barcode
    @user = User.find(params[:id])
    unless Barcode.where(id: params[:barcode]).exists?
      flash[:danger] = "No drink found with this barcode."
      redirect_to @user
    else
      @drink = Drink.find(Barcode.find(params[:barcode]).drink)
      buy_drink
    end
  end

  # GET /users/1/pay?amount=1.5
  def payment
    @user = User.find(params[:id])
    @user.payment(BigDecimal.new(params[:amount]))
    flash[:success] = "You just bought a drink and your new balance is #{show_amount(@user.balance)}. Thank you."
    if (@user.balance < 0) then
      flash[:warning] = "Your balance is below zero. Remember to compensate as soon as possible."
    end
    warn_user_if_audit
    no_resp_redir @user
  end

  # GET /users/stats
  def stats
    @user_count = User.count
    @balance_sum = User.sum(:balance)
    # stats.html.haml
  end

  private

  def buy_drink bar=false
    unless @drink.active?
      @drink.active = true
      @drink.save!
      flash[:info] = "The drink you just bought has been set to 'available'."
    end

    @user.buy(@drink, bar)
    unless bar
      flash[:success] = "You just bought a drink not in bar and your new balance is #{show_amount(@user.balance)}. Thank you."
    else
      flash[:success] = "You just bought a drink in bar and your new balance is #{show_amount(@user.balance)}. Thank you."
    end
    if (not bar and @user.balance < 0) then
      flash[:warning] = "Your balance is below zero. Remember to compensate as soon as possible."
    end
    warn_user_if_audit
    no_resp_redir @user.redirect ? users_url : @user
  end

  def user_params
    params.require(:user).permit(:name, :email, :balance, :active, :audit, :redirect)
  end
  
  def warn_user_if_audit
    if (@user.audit) then
      flash[:info] = "This transaction has been logged, because you set up your account that way. #{view_context.link_to 'Change?', edit_user_url(@user)}".html_safe
    end
  end
end
