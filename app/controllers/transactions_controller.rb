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
      format.json { render json: {status: :updated}, status: 201}
      format.js
    end
  end

  def destroy
    @transaction = current_company.transactions.find(params[:id])
    if @transaction.destroy
      @transaction.cleanup_after_destroy
      flash[:notice_header] = 'Transaction deleted.'
      flash[:notice] = "#{@transaction.custom_description} has been deleted."
      respond_to do |format|
        format.json { render json: {status: :destroyed}, status: 200}
        format.js
      end
    else
      flash[:alert_header] = 'Transaction not deleted.'
      flash[:alert] = "#{@transaction.custom_description} could not be deleted. Please try again."
      respond_to do |format|
        format.json { render json: {status: 'not found'}, status: :not_found }
        format.js
      end
    end
  end

  private

  def transaction_params
    params.require(:transaction).permit(:custom_description, :category_id, :essential, :duplicate, :duplicate_transaction_id, :duplicate_resolved_at)
  end

  def set_flash_message(transaction_params)
    if transaction_params[:custom_description]
      @notice_header = 'Transaction description updated.'
      @notice = "The transaction description is now #{transaction_params[:custom_description]}"
    elsif transaction_params[:category_id]
      @notice_header = 'Transaction category updated.'
      @notice = "Category for #{@transaction.custom_description} is now #{@transaction.category.category_list}"
    elsif transaction_params[:essential]
      essentiality = transaction_params[:essential] == 'true' ? 'essential' : 'non-essential'
      @notice_header = "Transaction marked as #{essentiality}."
      @notice = "#{@transaction.custom_description} is now being tracked as part of your #{essentiality} spend."
    elsif transaction_params[:duplicate]
      @notice_header = 'Resolved duplicate transaction.'
      @notice = "#{@transaction.custom_description} is not a duplicate anymore."
    end
  end
end
