class AddHealthyFlagToStacks < ActiveRecord::Migration[8.0]
  def change
    add_column :stacks, :healthy, :boolean, default: false, null: false
  end
end
