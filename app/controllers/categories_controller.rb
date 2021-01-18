class CategoriesController < ApplicationController
  def index
    if params[:query]
      @tx_id = params[:transaction_id]
      @categories = Category.where("hierarchy_string ILIKE ?", "%#{params[:query]}%").order('hierarchy_string asc')
    else
      @categories = Category.all.sort_by {|a| a.category_list}
    end
    respond_to do |format|
      format.html
      format.js
    end
  end
end
