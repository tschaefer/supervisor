class CreateStacks < ActiveRecord::Migration[7.2]
  def change
    create_table :stacks do |t|
      stack_base_attr(t)
      stack_git_ops_attr(t)
      stack_stats_attr(t)

      t.timestamps
    end
    add_index :stacks, :name, unique: true
    add_index :stacks, :uuid, unique: true
  end

  private

  def stack_base_attr(table)
    table.string :name, null: false
    table.string :uuid, null: false
    table.string :git_repository, null: false
    table.string :git_reference, null: false
    table.string :git_username
    table.string :git_token
    table.string :compose_file, null: false
    table.text   :compose_variables
    table.text   :compose_includes
  end

  def stack_git_ops_attr(table)
    table.string  :strategy, null: false
    table.integer :polling_interval
    table.string  :signature_header
    table.string  :signature_secret
  end

  def stack_stats_attr(table)
    table.integer :processed, default: 0
    table.integer :failed, default: 0
    table.datetime :last_run
  end
end
