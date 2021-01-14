class CategoriesController < ApplicationController
  def index
    @categories = Category.all.sort_by {|a| a.category_list}
    @category_nodes = Category.root_elements
  end

  def show
    @category = Category.find(params[:id])
    respond_to do |format|
      format.js
      format.json { render json: { category: @category } }
    end
  end
end
