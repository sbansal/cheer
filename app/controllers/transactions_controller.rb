class TransactionsController < ApplicationController
  def index
    @bank_accounts = current_user.bank_accounts
  end
  
  def show
    @transaction = current_user.transactions.find(params[:id])
    respond_to do |format|
      format.js
      format.json { render json: @transaction }
    end
  end
end
