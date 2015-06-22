require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/base'
require 'braintree'
require 'json'

class KeepTogether < Sinatra::Application
  Braintree::Configuration.environment = :sandbox
  Braintree::Configuration.merchant_id = ENV['BRAINTREE_MERCHANT_ID']
  Braintree::Configuration.public_key  = ENV['BRAINTREE_PUBLIC_KEY']
  Braintree::Configuration.private_key = ENV['BRAINTREE_PRIVATE_KEY']

  get '/client_token' do
     braintree_token.tap do |generated_client_token|
      log(generated_client_token: generated_client_token)
    end
  end

  post '/payment-methods' do
    params[:payment_method_nonce].tap do |payment_method_nonce|
      log(payment_method_nonce: payment_method_nonce)
      braintree_transaction(payment_method_nonce)
    end
  end

  private
  def braintree_token
    Braintree::ClientToken.generate(customer_id: ENV['BRAINTREE_CUSTOMER_ID'])
  end

  def braintree_transaction(payment_method_nonce)
    Braintree::Transaction.sale(
      amount:               rand(100),
      payment_method_nonce: payment_method_nonce
    )
  end

  def log(message)
    logger.info message.to_json
  end
end
