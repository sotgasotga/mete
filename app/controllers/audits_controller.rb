class AuditsController < ApplicationController

  before_action :authenticate_admin!, only: [:edit, :commit]
  after_action only: [:commit] do
     sign_out(current_admin) if current_admin
  end
  # GET /audits
  def index
    if params[:start_date] and params[:end_date]
      @start_date = parse_date params[:start_date]
      @end_date = parse_date params[:end_date]
    else
      # If no range is specified, show audits from the current year.
      @start_date = Date.new(Date.tomorrow.year)
      @end_date  = Date.tomorrow
    end
    if params[:user]
      @user = User.find(params[:user])
      @audits = Audit.where(user: @user).where(created_at: (@start_date..@end_date))
    else
      @audits = Audit.where(created_at: (@start_date..@end_date))
      @user = nil
    end

    @sum = @audits.sum(:difference)
    #@payments_sum = @audits.payments.sum(:difference).abs
    #@deposits_sum = @audits.deposits.sum(:difference)

    respond_to do |format|
      format.html #index.html.haml
      format.json { render json: {
        :sum => @sum,
        :payments_sum => @payments_sum,
        :deposits_sum => @deposits_sum,
        :audits => @audits
      }}
    end
  end

  def edit
    @register_balance = Audit.sum(:difference)
    respond_to do |format|
      format.html # # edit.html.haml
      format.json { render json: @audit }
    end
  end

   def commit
    puts params
    @change = params[:anything][:balance].to_i - Audit.sum(:difference)
    if Audit.create!(bank_difference: 0, difference: @change, drink: 0, user: nil) then
      flash[:success] = "You just changed the cash register balance the new balance is now #{Audit.sum(:difference)}"
    else
      flash[:error] = "You couldn't change the cash register balance the balance is still #{Audit.sum(:difference)}"
    end
    no_resp_redir audits_url
  end

  def destroy
    @audit = Audit.find(params[:id])
    if @audit.destroy
      flash[:success] = "Transaction successfully undone"
      no_resp_redir users_url
    else
      redirect_to users_url, error:  "Error while deleting transaction"
    end
  end


  private

  def parse_date data
    return Date.civil(data[:year].to_i, data[:month].to_i, data[:day].to_i)
  end
end
