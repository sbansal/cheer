class CategoriesController < ApplicationController
  def index
    @categories = Category.all.sort_by {|a| a.category_list}
  end
end
