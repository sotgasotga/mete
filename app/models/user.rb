class User < ActiveRecord::Base
  validates_presence_of :name
  validates_presence_of :email


  after_save do |user|
    Audit.create! bank_difference: user.balance - user.balance_before_last_save, difference: @purchased_drink.nil? ? 0 : @purchased_drink.price, drink: @purchased_drink.nil? ? 0 : @purchased_drink.id, user: user.audit? ? user.id : nil
  end

  def deposit(amount)
    self.balance += amount
    save!
  end

  def buy(drink, bar = false)
    self.balance -= drink.price unless bar
    @purchased_drink = drink
    save!
  end

  def payment(amount)
    self.balance -= amount
    save!
  end
end
