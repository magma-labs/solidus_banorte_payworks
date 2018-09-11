module Spree
  class PaymentMethod::BanortePayworks < PaymentMethod
    preference :merchant_id, :number, default: 0
    preference :user, :string, default: ''
    preference :password, :string, default: ''
    preference :terminal_id, :string, default: ''

    def gateway_class
      Spree::BanortePayworksPayment
    end

    def payment_profiles_supported?
      false
    end

    def source_required?
      true
    end

    def payment_source_class
      Spree::BanortePayworksPayment
    end

    def auto_capture?
      true
    end
  end
end