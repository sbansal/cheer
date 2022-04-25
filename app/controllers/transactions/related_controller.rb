class Transactions::RelatedController < ApplicationController
  def index
    @transaction = current_company.transactions.find(params[:transaction_id])
    @related_transactions = @transaction.related_transactions
    @aggregated_transactions = Transaction::AggregatedTransactions.new(@transaction.custom_description, @related_transactions)
    respond_to do |format|
      format.html { render layout: false }
    end
  end
end