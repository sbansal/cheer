class TransactionsController < ApplicationController
  include Pagy::Backend
  def index
    @period = params[:period] || Stat::THIS_MONTH
    @start_date, @end_date = parse_time_boundary(params)
    fetcher = TransactionsFetcher.call(current_company, @period, params)
    @duplicates_count = fetcher.duplicates_count
    @accounts_metadata = current_company.bank_accounts.map { |acc| [acc.id, acc.display_name] }.to_h
    @transactions = fetcher.aggregated_transactions&.transactions.includes([:bank_account])
    @transactions_by_category = @transactions.group_by(&:category).map {
      |category, transactions| Transaction::CategorizedTransaction.new(category, transactions)
    }.sort_by { |item| item.total_spend }
    @transactions_by_merchant = @transactions.group_by(&:merchant_name).map {
      |merchant_name, transactions| Transaction::AggregatedTransactions.new(merchant_name, transactions)
    }.sort_by { |item| item.total_spend }
    @pagy, @transactions = pagy(@transactions, items: 50)
    respond_to do |format|
      format.js
      format.html
    end
  end

  def show
    @transaction = current_company.transactions.find(params[:id])
    respond_to do |format|
      format.html
      format.js
      format.json { render json: @transaction }
    end
  end

  def edit
    @transaction = current_company.transactions.find(params[:id])
    @attribute = params[:attribute]
    respond_to do |format|
      format.html { render layout: false }
    end
  end

  def update
    @transaction = current_company.transactions.find(params[:id])
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
    @transaction = current_company.transactions.find(params[:id])
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
    params.require(:transaction).permit(:custom_description, :category_id, :essential)
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
