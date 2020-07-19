class TransactionsController < ApplicationController
  def index
    @transactions = current_user.transactions.includes([:category, :bank_account])
  end

  def show
    @transaction = current_user.transactions.find(params[:id])
    respond_to do |format|
      format.js
      format.json { render json: @transaction }
    end
  end
end
