require 'spec_helper'

RSpec.describe Spree::BanortePayworksController, type: :controller do
  describe 'POST to process_payment' do
    let(:order){create(:completed_order_with_pending_payment)}
    let(:payment){order.payments.first}
    let(:payload) do
      {
          MERCHANT_ID: 1234567,
          REFERENCE: 123456789123,
          CONTROL_NUMBER: '',
          CUST_REQ_DATE: '20180101 12:12:12.111',
          AUTH_REQ_DATE: '20180101 12:12:12.111',
          AUTH_RSP_DATE: '20180101 12:12:12.111',
          CUST_RSP_DATE: '20180101 12:12:12.111',
          PAYW_RESULT: 'A',
          AUTH_RESULT: '',
          PAYW_CODE: '',
          AUTH_CODE: '',
          TEXT: '',
          CARD_HOLDER: '',
          ISSUING_BANK: '',
          CARD_BRAND: '',
          CARD_TYPE: ''
      }
    end
    let(:PAYW_RESULT) { 'A' }

    context 'when payment is accepted' do
      it 'marks the payment as completed (paid)' do
        expect do
          post :process_payment, params: payload
        end.to change { payment.reload.state }.to('completed')
        expect(payment.order.payment_state).to eql('paid')
      end
    end

    context 'when payment is declined' do
      let(:PAYW_RESULT) { 'D' }
      it 'keeps the payment state as it is' do
        expect do
          post :process_payment, params: payload
        end.not_to change { payment.state }
      end
    end

    context 'when payment is rejected' do
      let(:PAYW_RESULT) { 'R' }
      it 'keeps the payment status as it is' do
        expect do
          post :process_payment, params: payload
        end.not_to change { payment.state }
      end
    end

    context 'when payment service is not available' do
      let(:PAYW_RESULT) { 'T' }
      it 'keeps the payment status as it is' do
        expect do
          post :create, params: payload
        end.not_to change { payment.state }
      end
    end
  end
end