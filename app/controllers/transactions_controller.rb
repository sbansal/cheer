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

  def edit
    @transaction = current_account.transactions.find(params[:id])
    @attribute = params[:attribute]
    respond_to do |format|
      format.html { render layout: false }
    end
  end

  def update
    @transaction = current_account.transactions.find(params[:id])
    @transaction.update(transaction_params)
    respond_to do |format|
      format.js
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

  private

  def transaction_params
    params.require(:transaction).permit(:custom_description)
  end
end
