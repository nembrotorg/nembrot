json.id     citation.id
json.lang   citation.lang

if params[:blurb] == 'true'
  citation_blurb_text, attribution_blurb_text = citation_blurb(citation.clean_body_with_parentheses)
  json.blurb_body         blurbify(citation_blurb_text, citation.books)
  json.blurb_attribution  blurbify(attribution_blurb_text, citation.books, 'citation.book.inline_html', 'citation.link.inline_html', false)
end

if params[:extended] == 'true'
  json.created_at         citation.created_at unless params[:compact]
  json.updated_at         citation.updated_at
  json.word_count         citation.word_count
  # This should use note_tags from Application controller
  tags = citation.tags.to_a.keep_if { |tag| Note.publishable.tagged_with(tag).size >= NB.tags_minimum.to_i }
  json.tags               tags, partial: './tags/tag', as: :tag
end

case params[:body]
  when 'raw'
    json.body citation.body
  when 'simple'
    json.body citation.clean_body
  when 'html'
    body, attribution = citation_blurb(citation.clean_body_with_parentheses, NB.citation_max_length.to_i)
    json.body         body
    json.attribution  attribution
end

# - cache [cache_buster(1), @citation, @tags] do
#
#   - document_title = "#{ @citation.headline } | #{ t('site.title') }"
#   - set_meta_tags title: document_title,
#                   description: @citation.body,
#                   open_graph: { title: @citation.title }
#
#   div class="#{ controller.controller_name }-#{ controller.action_name }"
#     nav = render_breadcrumbs builder: ::OrderedListBuilder
#     article
#       section#content lang=lang_attr(@citation.lang) dir=dir_attr(@citation.lang)
#         = render 'header', title: t('citations.index.title', id: @citation.id), subtitle: nil, document_title: document_title
#         section  lang=lang_attr(@citation.lang) dir=dir_attr(@citation.lang)
#           - citation_text, attribution = citation_blurb(@citation.clean_body_with_parentheses, NB.citation_max_length.to_i)
#           figure.citation
#             blockquote= blurbify(citation_text, @citation.books)
#             figcaption= blurbify(attribution, @citation.books, 'citation.book.inline_html', 'citation.link.inline_html', false)
#       = render 'notes/tag_list', tags: @tags unless @tags.empty?
