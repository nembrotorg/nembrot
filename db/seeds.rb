# We start with a blank database.
# Or we can seed from CloudService.
# Or add manually:

# cloud_service = CloudService.where( :name => 'CLOUDSERVICE01' ).first_or_create

# cloud_note = CloudNote.where(:cloud_note_identifier => 'ABC101', :cloud_service_id => cloud_service.id).first_or_initialize
# note = Note.new(
#     :title => 'All who Wish to Be are Gourmands his ultimate absurdity',
#     :body => 'There are individuals to whom nature has refused a degree of attention, without which the most succulent food passes unperceived.\nPhysiology has already recognized the first of these varieties, by exhibiting the tongue of those unfortunate men who are badly provided with the means of appreciating flavors and tastes. Such persons have but an obtuse sensation, for to them taste is what light is to the blind.\nThe second of these varieties is composed of absent minded men, of ambitious persons, and others, who wish to attend to two things at once, and who eat only to eat.',
#     :external_updated_at => 'Mon, 30 Jul 2012 12:10:00 UTC +00:00',
#     :tag_list => 'food, taste, sensualist'
#   )
# note.save!
# cloud_note.note_id = note.id
# cloud_note.save!

# cloud_note = CloudNote.where(:cloud_note_identifier => 'ABC101', :cloud_service_id => cloud_service.id).first_or_initialize
# note = Note.find(cloud_note.note_id)
# note.update_attributes(
#     :title => 'All who Wish to Be Gourmands',
#     :body => 'There are individuals to whom nature has refused a degree of attention, without which the most succulent food passes unperceived.\nPhysiology has already recognized the first of these varieties, by exhibiting the tongue of those unfortunate men who are badly provided with the means of appreciating flavors and tastes. Such persons have but an obtuse sensation, for to them taste is what light is to the blind.\nThe second of these varieties is composed of absent minded men, of ambitious persons, and others, who wish to attend to two things at once, and who eat only to eat.',
#     :external_updated_at => 'Mon, 30 Jul 2012 12:10:01 UTC +00:00',
#     :tag_list => 'food, gourmand, taste'
#   )
# note.save!
# cloud_note.note_id = note.id
# cloud_note.save!
