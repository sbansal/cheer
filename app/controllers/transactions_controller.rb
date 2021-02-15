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
    @category_list = Category.find(transaction_params[:category_id]).category_list if transaction_params[:category_id]
    @custom_description = transaction_params[:custom_description]
    if params[:bulk_update]
      @related_transactions = @transaction.related_transactions
      @transaction.update_related(transaction_params, @related_transactions.map(&:id))
    end
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

  def related
    @transaction = current_account.transactions.find(params[:id])
    @related_transactions = @transaction.related_transactions
    @categorized_transactions = CategorizedTransaction.new(@transaction.category.descriptive_name, @related_transactions)
    respond_to do |format|
      format.html { render layout: false }
    end
  end

  private

  def transaction_params
    params.require(:transaction).permit(:custom_description, :category_id)
  end
end
