module ApplicationHelper

  def show_amount(price)
    return 'n/a' if price.blank?
    sprintf('%.2f EUR', price)
  end

  def drink_name(drink)
    drink = Drink.find_by(:id => drink)
    if drink.nil?
      return "n/a"
    else
      return drink.name
    end
  end
end
