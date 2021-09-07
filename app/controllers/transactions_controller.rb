class TransactionsController < ApplicationController
  include Pagy::Backend
  def index
    if params[:search_query].blank?
      @transactions = current_account.transactions.includes([:category])
    else
      @transactions = Transaction.where('custom_description ILIKE ? OR description ILIKE ? OR merchant_name ILIKE ?',
        "%#{params[:search_query]}%", "%#{params[:search_query]}%", "%#{params[:search_query]}%")
        .and(Transaction.where(user_id: current_account.user_ids))
        .includes([:category])
        .order('occured_at desc')
    end
    @pagy, @transactions = pagy(@transactions, items: 50)
    respond_to do |format|
      format.html
      format.js
    end
  end

  def show
    @transaction = current_account.transactions.find(params[:id])
    respond_to do |format|
      format.html
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

  def new
    respond_to do |format|
      format.js
    end
  end

  def create
    @transaction = current_account.transactions.new(user_id: current_user.id)
    if @transaction.create(new_transaction_params)
      @notice_header = 'Transaction created.'
      @notice = "Successfully created the transaction - #{@transaction.description}."
    else
      flash[:alert_header] = 'Transaction not updated.'
      flash[:alert] = 'Transaction update failed. Please try again.'
    end
    respond_to do |format|
      format.js
    end
  end

  def update
    @transaction = current_account.transactions.find(params[:id])
    if params[:bulk_update]
      related_ids = @transaction.related_transactions.map(&:id)
      RelatedTransactionsCreatorJob.perform_later(
        @transaction.to_global_id.to_s,
        transaction_params,
        related_ids,
      )
    end
    if @transaction.update(transaction_params)
      set_flash_message(transaction_params)
    else
      flash[:alert_header] = 'Transaction not updated.'
      flash[:alert] = 'Transaction update failed. Please try again.'
    end
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

  def related
    @transaction = current_account.transactions.find(params[:id])
    @related_transactions = @transaction.related_transactions
    @aggregated_transactions = AggregatedTransactions.new(@related_transactions)
    respond_to do |format|
      format.html { render layout: false }
    end
  end

  private

  def transaction_params
    params.require(:transaction).permit(:custom_description, :category_id, :essential)
  end

  def new_transaction_params
    params.require(:transaction).permit(:description, :category_id, :essential, :amount, :occured_at, :bank_account_id)
  end

  def set_flash_message(transaction_params)
    @notice_header = 'Transaction updated.'
    if transaction_params[:custom_description]
      @notice = "Successfully updated the transaction description."
    elsif transaction_params[:category_id]
      @notice = "Successfully updated the transaction category."
    elsif transaction_params[:essential]
      essentiality = transaction_params[:essential] == 'true' ? 'essential' : 'non-essential'
      @notice = "Successfully marked the transaction as #{essentiality}."
    end
  end
end
