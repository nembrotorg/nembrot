namespace :seed do

  desc 'Seed tasks'

  task distance: :environment do |t, args|

    desc 'Seed Notes and versions with Leveshtein distance'

    Note.all.each do |n|

      previous_body = n.versions.empty? ? '' : n.versions.last.reify.body
      n.distance = Levenshtein.distance(previous_body, n.body)
      n.save!

      (1..(n.versions.size)).each do |i|
        diffed_note = DiffedNoteVersion.new(n, i)
        version = n.versions.find_by_sequence(i)
        version.distance = Levenshtein.distance(diffed_note.previous_body, diffed_note.body)
        version.save!
      end
    end
  end

  task is_citation: :environment do |t, args|

    desc 'Updates is_citation? for each note'

    Note.all.each do |n|
      n.hide = false
      n.listable = true
      n.save
    end
  end

  task update_note: :environment do |t, args|

    desc 'Update word count etc by saving each note'

    Note.all.each do |n|
      n.save!
    end
  end

  task external_updated_at: :environment do |t, args|

    desc 'Add external_updated_at to notes and versions'

    Note.all.each do |n|
      n.versions.each do |v|
        v.external_updated_at = v.reify.external_updated_at
        v.save!
      end
    end
  end
end
