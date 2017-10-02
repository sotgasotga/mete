module DrinksHelper
    def generate_buy_path(user, drink, bar)
        if(user) then
            buy_user_path(user, :drink => drink.id, :bar => true)
        else
            anonymous_buy_path(:drink => drink.id)
        end
    end
end
