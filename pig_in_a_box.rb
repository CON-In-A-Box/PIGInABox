require 'bundler'
Bundler.require

require 'sinatra'
require 'sinatra/json'

include AuthorizeNet::API

def get_transaction
  Transaction.new(
    ENV['ANET_LOGIN_ID'],
    ENV['ANET_KEY'],
    gateway: (ENV['APP_ENV']=='production' ? :production : :sandbox)
  )
end

def get_request(params)
  request = CreateTransactionRequest.new

  request.transactionRequest = TransactionRequestType.new
  request.transactionRequest.amount = params[:amount]
  request.transactionRequest.payment = PaymentType.new
  request.transactionRequest.payment.opaqueData = OpaqueDataType.new(params[:opaqueData][:dataDescriptor], params[:opaqueData][:dataValue])
  request.transactionRequest.customer = CustomerDataType.new(nil, nil, params[:customerEmail])
  request.transactionRequest.transactionType = TransactionTypeEnum::AuthCaptureTransaction
  request.transactionRequest.order = OrderType.new(DateTime.now.to_f, params[:orderDetals])

  request
end

def process_response(response)
  retVal = {}
  if response.blank?
    @error = "Response was nil. Card not charged"
  else
    if response.messages.resultCode == MessageTypeEnum::Ok
      if response.transactionResponse != nil && response.transactionResponse.messages != nil
        @message = "Successful charge AUTH: #{response.transactionResponse.authCode}"
        retVal[:authCode] = response.transactionResponse.authCode
        retVal[:responseCode] = response.transactionResponse.responseCode
        retVal[:accountNumber] = response.transactionResponse.accountNumber
        retVal[:messages] = response.transactionResponse.messages.messages.collect do |m|
          {
            code: m.code,
            description: m.description
          }
        end
      else
        @errors = "Transaction Failed"
        retVal[:errors] = response.transactionResponse.errors.errors.collect do |e|
          {
            code: e.errorCode,
            description: e.errorText
          }
        end
      end
    else
      @errors = "Transaction Failed"
      if response.transactionResponse != nil && response.transactionResponse.errors != nil
        retVal[:errors] = response.transactionResponse.errors.errors do |e|
          {
            code: e.errorCode,
            description: e.errorText
          }
        end
      else
        retVal[:errors] = response.messages
      end
    end
    
    retVal
  end
end

configure :development do
  set :logging, Logger::DEBUG
end

get '/' do
  slim :index, layout: :application, layout_engine: :erb
end


namespace '/api/v1' do
  #
  # On success returns:
  # {
  #   authCode:
  #   responseCode:
  #   messages: [ { code:, description:}, ...]
  # }
  #
  # On error returns:
  # {
  #   errors: [ { code:, description:}, ...]
  # }
  #
  post '/payments' do
    content_type :json
    param :opaqueData, Hash, requred: true
    param :amount, Float, required: true
    param :customerEmail, String, required: true
    param :orderDetails, String

    if request.xhr?
      json process_response get_transaction.create_transaction(get_request(params))
    else
      error 418 # I am a teapot
    end
  end
end
