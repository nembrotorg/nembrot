params = { :note => [{
    :external_identifier => 'ABC101',
    :note_versions_attributes => [
      {
        :title => 'All who Wish to Be are Gourmands his ultimate absurdity',
        :body => 'There are individuals to whom nature has refused a degree of attention, without which the most succulent food passes unperceived.\nPhysiology has already recognized the first of these varieties, by exhibiting the tongue of those unfortunate men who are badly provided with the means of appreciating flavors and tastes. Such persons have but an obtuse sensation, for to them taste is what light is to the blind.\nThe second of these varieties is composed of absent minded men, of ambitious persons, and others, who wish to attend to two things at once, and who eat only to eat.',
        :external_updated_at => 'Mon, 30 Jul 2012 12:00:00 UTC +00:00'
      },
      {
        :title => 'All who Wish to Be Gourmands',
        :body => 'There are individuals to whom nature has refused a degree of attention, without which the most succulent food passes unperceived.\nPhysiology has already recognized the first of these varieties, by exhibiting the tongue of those unfortunate men who are badly provided with the means of appreciating flavors and tastes. Such persons have but an obtuse sensation, for to them taste is what light is to the blind.\nThe second of these varieties is composed of absent minded men, of ambitious persons, and others, who wish to attend to two things at once, and who eat only to eat.',
        :external_updated_at => 'Mon, 30 Jul 2012 12:00:01 UTC +00:00'
      },
      {
        :title => 'All who Wish to Be are Not Gourmands',
        :body => 'There are individuals to whom nature has refused a finenese of organs and a degree of attention, without which the most succulent food passes unperceived.\nPhysiology has already recognized the first of these varieties, by exhibiting the tongue of those unfortunate men who are badly provided with the means of appreciating flavors and tastes. Such persons have but an obtuse sensation, for to them taste is what light is to the blind.\nThe second of these varieties is composed of absent minded men, of ambitious persons, and others, who wish to attend to two things at once, and who eat only to eat.',
        :external_updated_at => 'Mon, 30 Jul 2012 12:00:02 UTC +00:00'
      }
  ]},
  {
    :external_identifier => 'ABC102',
    :note_versions_attributes => [
      {
        :title => 'Origin of Pleasures of the Table',
        :body => 'Meals, as we understand word, began at the second of history. That is to say as soon as we ceased to live on fruits alone. The preparation and distribution of food made the union of the family a necessity, at least once a day. The heads of families then distributed the produce of the chase, and grown children did as much for their parents.\nThese collections, limited at first to near relations, were ultimately extended to neighbors and friends.\nAt a later day when the human species was more widely extended, the weary traveler used to sit at such boards and tell what he had seen in foreign lands. Thus hospitality was produced, and its rights were recognized everywhere. There was never any one so ferocious as not to respect him who had partaken of his bread and salt.',
        :external_updated_at => 'Mon, 30 Jul 2012 12:00:00 UTC +00:00'
      },
      {
        :title => 'Origin of the Pleasures of Table',
        :body => 'Meals, as we understanxd the word, began at the second stage of the history of humanity. That is to say as soon as we ceased to live on fruits alone. The preparation and distribution of food made the union of the family a necessity, at least once a day. The heads of families then distributed the produce of the chase, and grown children did as much for their parents.\nThese collections, limited at first to near relations, were ultimately extended to neighbors and friends.\nAt a later day when the human species was more widely extended, the weary traveler used to sit at such boards and tell what he had seen in foreign lands. Thus hospitality was produced, and its rights were recognized everywhere. There was never any one so ferocious as not to respect him who had partaken of his bread and salt.',
        :external_updated_at => 'Mon, 30 Jul 2012 12:00:01 UTC +00:00'
      },
      {
        :title => 'Origin of the Pleasures of the Table',
        :body => 'Meals, as we understand the word, began at the second stage of the history of humanity. That is to say as soon as we ceased to live on fruits alone. The preparation and distribution of food made the union of the family a necessity, at least once a day. The heads of families then distributed the produce of the chase, and grown children did as much for their parents.\nThese collections, limited at first to near relations, were ultimately extended to neighbors and friends.\nAt a later day when the human species was more widely extended, the weary traveler used to sit at such boards and tell what he had seen in foreign lands. Thus hospitality was produced, and its rights were recognized everywhere. There was never any one so ferocious as not to respect him who had partaken of his bread and salt.',
        :external_updated_at => 'Mon, 30 Jul 2012 12:00:03 UTC +00:00'
      }
  ]},
  {
    :external_identifier => 'ABC103',
    :note_versions_attributes => [
      {
        :title => 'Digestion',
        :body => 'We never see what we eat, says an old adage, except what we digest.\nHow few, however, know what digestion is, though it is a necessity equalizing rich and poor, the shepherd and the king.\nThe majority of persons who, like M. Jourdan, talked prose without knowing it, digest without knowing how; for them I make a popular history of digestion, being satisfied that M. Jourdan was much better satisfied when his master told him that he wrote prose. To he fully acquainted with digestion, one must know hoth its antecedents and consequents.',
        :external_updated_at => 'Mon, 30 Jul 2012 12:00:00 UTC +00:00'
      },
      {
        :title => 'Digestion',
        :body => 'We never see what we eat, says an old adage, what we digest.\nHow few, however, know what digestion is, though it is a necessity equalizing rich and poor, the shepherd and the king.\nThe majority of persons who, like M. Jourdan, talked prose without knowing it, digest without knowing how; for them I make a popular history of digestion, being satisfied that M. Jourdan was much better satisfied when his master told him that he wrote prose. To he fully acquainted with digestion, one must know hoth its antecedents and consequents.',
        :external_updated_at => 'Mon, 30 Jul 2012 12:00:01 UTC +00:00'
      },
      {
        :title => 'On Digestion',
        :body => 'We never see, says an adage, what we digest.\nHow few, however, know what digestion is, though it is a necessity equalizing rich and poor, the shepherd and the king.\nThe majority of persons who, like M. Jourdan, talked prose without knowing it, digest without knowing how; for them I make a popular history of digestion, being satisfied that M. Jourdan was much better satisfied when his master told him that he wrote prose. To he fully acquainted with digestion, one must know hoth its antecedents and consequents.',
        :external_updated_at => 'Mon, 30 Jul 2012 12:00:03 UTC +00:00'
      }
  ]}
]}

notes = Note.create!(params[:note]);

# SEED NOTES USING evernote import if set up
