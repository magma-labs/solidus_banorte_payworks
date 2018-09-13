module Spree
  class PaymentMethod::BanortePayworks < ::Spree::PaymentMethod
    preference :merchant_id, :string, default: 0
    preference :user, :string, default: ''
    preference :password, :string, default: ''
    preference :terminal_id, :string, default: ''

    def gateway_class
      ::Spree::Gateway::BanortePayworks2
    end

    def payment_profiles_supported?
      true
    end

    def create_profile(payment)
      payment_source_class.create_profile(payment)
    end

    def source_required?
      true
    end

    def payment_source_class
      ::Spree::Gateway::BanortePayworks2
    end

    def auto_capture?
      true
    end

    def actions
      %w(authorize capture void credit)
    end
  end
end
