class RenameUriToRemoteUri < ActiveRecord::Migration[8.1]
  def change
    rename_column :quotes, :uri, :remote_uri
  end
end
