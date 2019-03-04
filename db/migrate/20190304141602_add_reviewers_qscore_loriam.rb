class AddReviewersQscoreLoriam < ActiveRecord::Migration
  def change
  	add_column :activity_objects, :reviewers_qscore_loriam, :decimal, :precision => 12, :scale => 6
    add_column :activity_objects, :reviewers_qscore_loriam_int, :integer
  end
end
