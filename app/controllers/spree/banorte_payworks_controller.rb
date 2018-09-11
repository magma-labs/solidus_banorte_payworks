module Spree
  class BanortePayworksController < StoreController
    def process_payment
      # TODO
      case params[:PAYW_RESULT]
      when 'A'
        # payment accepted
      when 'D'
        # payment declined
      when 'R'
        # payment rejected
      when 'T'
        # payment service unavailable
      else
        # ERROR
      end
    end
  end
end