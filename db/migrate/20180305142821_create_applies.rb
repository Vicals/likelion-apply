class CreateApplies < ActiveRecord::Migration[5.1]
  def change
    create_table :applies do |t|
      t.string :univ
      t.string :title
      t.string :name
      t.string :email
      t.string :phone
      t.string :course
      t.string :grade
      t.string :reason
      t.string :service
      t.string :q1
      t.string :a1
      t.string :q2
      t.string :a2
      t.string :q3
      t.string :a3
      t.string :a4
      
      t.timestamps
    end
  end
end
