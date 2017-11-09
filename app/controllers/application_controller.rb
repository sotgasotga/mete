class ApplicationController < ActionController::Base
  def no_resp_redir(dest)
    respond_to do |format|
      format.html { redirect_to dest }
      format.json { head :no_content }
    end
  end

  before_action :set_raven_context

  def anonymous
    @user = 0
    @drinks = Drink.order(active: :desc).order("name COLLATE nocase")
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  def anonymous_buy
    @drink = Drink.find(params[:drink])
    unless @drink.active?
      @drink.active = true
      @drink.save!
      flash[:info] = "The drink you just bought has been set to 'available'."
    end
    audit = Audit.create! bank_difference: 0, difference: @drink.price, drink: @drink.nil? ? 0 : @drink.id, user: nil
    flash[:success] = { view: 'bought_drink_flash', audit: audit }
    no_resp_redir users_url
  end

  private

  def set_raven_context
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end
end
