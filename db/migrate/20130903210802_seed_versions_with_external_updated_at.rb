class SeedVersionsWithExternalUpdatedAt < ActiveRecord::Migration
  def up
    Note.all.each do |n|
      n.versions.each do |v|
        v.external_updated_at = v.reify.external_updated_at
        v.save!
      end
    end
  end

  def down
    # Nothing to reverse
  end
end
