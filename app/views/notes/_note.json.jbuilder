json.id                 note.id
json.canonical_url      "http://#{ NB.host }#{ note_or_feature_path(note) }"
json.main_title         note.main_title
json.subtitle           note.subtitle
json.introduction       note.introduction
json.feature_title      note.feature
json.feature_subtitle   note.feature_id
json.lang               note.lang
json.author             NB.author

if params[:blurb] == 'true'
  blurb_length = blurb_length || NB.blurb_length.to_i
  headline, blurb = blurb(note.main_title, note.subtitle, note.clean_body, note.introduction, blurb_length)

  json.blurb_title simple_blurbify(headline)
  json.blurb_body blurbify(blurb, note.books)
end

if params[:extended] == 'true'
  json.licence_url        "http://creativecommons.org/licenses/by-nc-sa/4.0/"

  json.created_at         note.created_at unless params[:compact]
  json.updated_at         note.updated_at
  json.version            note.versions.length + 1
  json.edit_distance      note.distance
  json.word_count         note.word_count

  json.instructions       note.instruction_list.uniq.join(',')
  # This should use note_tags from Application controller
  tags = note.tags.to_a.keep_if { |tag| Note.publishable.tagged_with(tag).size >= NB.tags_minimum.to_i }
  json.tags               tags, partial: './tags/tag', as: :tag
end

case params[:body]
  when 'raw'
    json.body note.body
  when 'simple'
    json.body note.clean_body
  when 'html'
    json.body bodify(note.body, note.books)
end
