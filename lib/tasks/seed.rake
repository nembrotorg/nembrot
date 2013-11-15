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
