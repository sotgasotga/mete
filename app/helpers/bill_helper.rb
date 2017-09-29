module BillHelper
    def bill_path_generate(action, user, amount, target = nil)
        if(action == "deposit")
            return deposit_user_path(user, :amount => amount)
        elsif(action == "retrieve") 
            return retrieve_user_path(user, :amount => amount)
        else
            return transaction_to_user_path(user, :to_id => target, :amount => amount)
        end
    end

    def bill_sign(action)
        case action
            when "deposit"
                '+'
            when "retrieve"
                '-'
            else
                ''
            end
        end

end
