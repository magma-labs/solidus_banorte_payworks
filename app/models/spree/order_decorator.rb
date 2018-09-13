Spree::Order.class_eval do
  state_machine.before_transition to: :confirm, do: :verify_preauthorization

  def verify_preauthorization
    gateway = self.payments.last.source
    if gateway.class.equal? Spree::Gateway::BanortePayworks2
      unless gateway.gateway_payment_profile_id
        errors[:payments] << "Hay un problema con tu tarjeta, intenta nuevamente o usa otro medio de pago"
        return false
      end
    end
  end
end
