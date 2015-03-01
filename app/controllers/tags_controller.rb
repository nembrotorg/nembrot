class TagsController < ApplicationController

  add_breadcrumb I18n.t('tags.index.title'), :tags_path

  def index
    page_number = params[:page] ||= 1
    all_tags = Note.publishable.tag_counts_on(:tags, at_least: Setting['advanced.tags_minimum'].to_i)

    @tags = all_tags.page(page_number).per(Setting['advanced.tags_index_per_page'].to_i).load
    @references_count = all_tags.to_a.sum { |t| t.count }
    @tags_count = all_tags.size
  end

  def show
    @tag = Tag.find_by_slug(params[:slug]) # .friendly.find is not working here
    @notes = Note.publishable.listable.blurbable.tagged_with(@tag.name)
    @citations = Note.publishable.citations.tagged_with(@tag.name)
    @all_interrelated_notes_and_features = Note.interrelated.publishable.notes_and_features
    @all_interrelated_citations = Note.interrelated.publishable.citations

    @word_count = @notes.sum(:word_count)
    @map = mapify(@notes.mappable)

    add_breadcrumb @tag.name, tag_path(params[:slug])

    rescue
     flash[:error] = I18n.t('tags.show.not_found', slug: 'nonexistent')
     redirect_to tags_path
  end

  def map
    @tag = Tag.find_by_slug(params[:slug]) # .friendly.find is not working here
    @notes = Note.publishable.listable.tagged_with(@tag.name)
    @word_count = @notes.sum(:word_count)

    @map = mapify(@notes.mappable)

    add_breadcrumb @tag.name, tag_path(params[:slug])
    add_breadcrumb I18n.t('map'), tag_map_path(params[:slug])
  end
end
