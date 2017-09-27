module BillHelper
    def bill_path_generate(deposit, user, amount)
        if(deposit == true)
            return deposit_user_path(user, :amount => amount)
        else
            return retrieve_user_path(user, :amount => amount)
        end
    end
end
