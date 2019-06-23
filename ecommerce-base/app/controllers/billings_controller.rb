class BillingsController < ApplicationController
  
  before_action :authenticate_user!

def index
  @billings = current_user.billings
end


def execute

  # render json:params
  paypal_payment = PayPal::SDK::REST::Payment.find(params[:paymentId])
  if paypal_payment.execute(payer_id: params[:PayerID])

          amount = paypal_payment.transactions.first.amount.total
          billing = Billing.create(
          user: current_user,
          code: paypal_payment.id,
          payment_method: 'paypal',
          amount: amount,
          currency: 'USD' )

  orders = current_user.orders.cart
  orders.update_all(payed: true, billing_id: billing.id)
  redirect_to root_path, notice: "La compra se realizó con éxito!"

  else
    render plain: "No se puedo generar el cobro en PayPal."
  end

end
def pre_pay

     #Redirige a PayPal

     orders = current_user.orders.cart
     total = orders.get_total
     items = get_item_hash(orders)
     # Build Payment object
    @payment = PayPal::SDK::REST::Payment.new({
    :intent =>  "sale",
    :payer =>  {
      :payment_method =>  "paypal" },
    :redirect_urls => {
      :return_url => execute_billings_url,
      :cancel_url => "http://localhost:3000/" },
    :transactions =>  [{
      :item_list => {
        :items => items
      },
      :amount =>  {
        :total =>  total,
        :currency =>  "USD" },
      :description =>  "Carrito de compra" }]})

     
      
      if @payment.create
        redirect_url = @payment.links.find{|v| v.method == "REDIRECT" }.href
        redirect_to redirect_url
        # render json: @payment.to_json

      else
        render json: @payment.error
          
      end
      

   

end

private
def get_item_hash(orders)

  items = orders.map do |order|
    item = {}
    item[:name] = order.product.name
    item[:sku] = order.id.to_s
    item[:price] = order.price.to_s
    item[:currency] = 'USD'
    item[:quantity] = order.quantity
    item
 end

end

end
