class UsersController < ApplicationController

  def index
  end

  def create
  end

  def show
  end

  def destroy
  end

  def payment
    Stripe.api_key = ENV['STRIPE_KEY']

    intent = Stripe::PaymentIntent.create({
      amount: 100,
      currency: 'usd',
      metadata: {integration_check: 'accept_a_payment'},
    })
  end

end
