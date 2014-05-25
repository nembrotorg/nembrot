class HomeController < ApplicationController

  def index
    @all_interrelated_notes_and_features = Note.channelled(@current_channel).interrelated.publishable.notes_and_features
    @all_interrelated_citations = Note.channelled(@current_channel).interrelated.publishable.citations

    @note = @home_note
    # REVIEW: This could go in the Note model as part of channelled
    #  However, channelled would need to be a scope so that it returns an ActiveRecord
    #  relation rather than an array.
    @note = @default_note if @note.nil?

    interrelated_notes_features_and_citations
    note_tags(@note)
    @map_this_marker = note_map(@note)
    note_source(@note)

    get_promoted_notes(@note)

    # FIXME: Cache this
    all_notes = Note.channelled(@current_channel).publishable.listable.blurbable
    mapify(all_notes.mappable)

    @channels = Channel.promoted.first(12)
    @channels = (@channels + Channel.promotable.first(12 - @channels.size)).uniq if @channels.size < 12
  end

  def default_url_options
    # return { channel: @current_channel.slug } unless @current_channel.name == 'default'
    { channel: @current_channel.slug }
  end
end
