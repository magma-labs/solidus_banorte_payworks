module Spree
  class Gateway::BanortePayworks2 < ::Spree::CreditCard
    attr_accessor :server, :test_mode, :merchant_id, :user, :password, :terminal_id

    BANORTE_PAYWORKS_URL = 'https://via.pagosbanorte.com/payw2'

    def purchase(amount, source, gateway_options)
      payload = {
          REFERENCE: source.gateway_payment_profile_id,
          CMD_TRANS: 'POSTAUTORIZACION',
          MODO_ENTRADA: 'MANUAL',
          MONTO: amount / 100
      }
      result = perform(payload)
      if result.success?
        source.payments.map(&:complete)
      end
      result
    end

    def create_authorization(payment)
      return if payment.source.gateway_payment_profile_id
      card = payment.source
      payload = {
          NUMERO_TARJETA: card.number,
          FECHA_EXP: Date.new(card.year.to_i, card.month.to_i, 1).strftime('%m%y'),
          CODIGO_SEGURIDAD: card.verification_value,
          MODO_ENTRADA: 'MANUAL',
          CMD_TRANS: 'PREAUTORIZACION',
          MONTO: payment.amount.to_s
      }
      result = perform(payload)
      if result.success?
        payment.source.update_attribute(:gateway_payment_profile_id, result.params['authorization'])
      else
        payment.invalidate!
        raise ::Spree::Core::GatewayError.new(result.message)
      end
    end

    def credit(amount, source, gateway_options, origin)
      payload = {
          REFERENCE: source.gateway_payment_profile_id,
          CMD_TRANS: 'DEVOLUCION',
          MODO_ENTRADA: 'MANUAL',
          MONTO: amount / 100
      }
      perform(payload)
    end

    def void(amount, source, gateway_options)
      payload = {
          REFERENCE: source.gateway_payment_profile_id,
          CMD_TRANS: 'CANCELACION',
          MODO_ENTRADA: 'MANUAL'
      }
      result = perform(payload)
      if result.success?
        source.payments.map(&:void)
      end
      result
    end

    def self.create_profile(payment)
      new(payment.payment_method.preferences).create_authorization(payment)
    end

    private

    def perform(payload = {})
      begin
        url = URI(BANORTE_PAYWORKS_URL)
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true

        request = Net::HTTP::Post.new(url)

        request.body = base_params.merge(payload).to_query

        response = http.request(request)
        gateway_result = response.header['resultado_payw']
        case gateway_result
          when 'A'
            ActiveMerchant::Billing::Response.new(true, {}, {authorization: response.header['referencia']})
          when 'D', 'R', 'T'
            ActiveMerchant::Billing::Response.new(false, CGI.unescape(response.header['texto']), {})
        end
      rescue Exception => e
        ActiveMerchant::Billing::Response.new(false, {}, {})
      end
    end

    def base_params
      {
          ID_AFILIACION: merchant_id,
          USUARIO: user,
          CLAVE_USR: password,
          ID_TERMINAL: terminal_id,
          MODE: gateway_mode
      }
    end

    def gateway_mode
      test_mode ? 'AUT' : 'PRD'
    end

  end
end
