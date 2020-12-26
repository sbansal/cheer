class TransactionsController < ApplicationController
  def index
    @transactions = current_account.transactions.includes([:category])
  end

  def show
    @transaction = current_account.transactions.find(params[:id])
    respond_to do |format|
      format.js
      format.json { render json: @transaction }
    end
  end

  def destroy
    @transaction = current_account.transactions.find(params[:id])
    if @transaction.destroy
      respond_to do |format|
        format.html { redirect_to transactions_path }
        format.json { render json: {status: :destroyed}, status: 200}
      end
    else
      render json: {status: 'not found'}, status: :not_found
    end
  end
end
