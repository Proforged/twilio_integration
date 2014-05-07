require "sinatra"
require "endpoint_base"

Dir['./lib/**/*.rb'].each &method(:require)

class TwilioEndpoint < EndpointBase::Sinatra::Base
  set :logging, true

  Honeybadger.configure do |config|
    config.api_key = ENV['HONEYBADGER_KEY']
    config.environment_name = ENV['RACK_ENV']
  end

  post '/send_sms' do
    body    = @payload['sms']['message']
    phone   = @payload['sms']['phone']
    from    = @payload['sms']['from']

    message = Message.new(@config, body, phone, from)
    message.deliver

    result 200, "SMS #{body} sent to #{phone}"
  end

  post '/sms_order' do
    order  = Order.new(@config, @payload['order'])
    body   = "Hey #{order.customer_name}! Your order #{order.number} has been received."

    message = Message.new(@config, body, order.customer_phone)
    message.deliver

    result 200, "SMS confirmation sent to #{order.customer_phone}"
  end

  post '/sms_ship' do
    shipment = @payload['shipment']['number'] || @payload['shipment']['id']
    order    = @payload['shipment']['order_id'] || @payload['shipment']['order_number']
    name     = @payload['shipment']['shipping_address']['firstname']
    phone    = @payload['shipment']['shipping_address']['phone']
    body     = "Hey #{name}! Your shipment \##{shipment} for order \##{order} has shipped."

    message = Message.new(@config, body, phone)
    message.deliver

    result 200, "SMS confirmation sent to #{phone}"
  end

  post '/sms_cancel' do
    order  = Order.new(@config, @payload['order'])
    body   = "Hey #{order.customer_name}! Your order #{order.number} has been canceled."

    message = Message.new(@config, body, order.customer_phone)
    message.deliver

    result 200, "SMS confirmation sent to #{order.customer_phone}"
  end
end
