class RenamePromptToContent < ActiveRecord::Migration[7.0]
  def change
    rename_column :messages, :prompt, :content
  end
end
