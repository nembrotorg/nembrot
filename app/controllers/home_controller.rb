class HomeController < ApplicationController

  def index
    @all_interrelated_notes_and_features = Note.channelled(@current_channel).interrelated.publishable.notes_and_features
    @all_interrelated_citations = Note.channelled(@current_channel).interrelated.publishable.citations

    @note = @home_note
    # REVIEW: This could go in the Note model as part of channelled
    #  However, channelled would need to be a scope so that it returns an ActiveRecord
    #  relation rather than an array.
    if @note.nil?
      @note = @default_note
      @current_channel.update_attributes(has_notes: false) if @current_channel.has_notes == true
    else
      @current_channel.update_attributes(has_notes: true) if @current_channel.has_notes == false
    end

    interrelated_notes_features_and_citations
    # note_tags(@note)
    @tags = []
    @map_this_marker = note_map(@note)
    note_source(@note)

    get_promoted_notes(@note)

    # FIXME: Cache this
    all_notes = Note.includes(:resources).channelled(@current_channel).publishable.listable.blurbable
    mapify(all_notes.mappable)

    @channels = Channel.promoted.first(30)
    @channels = (@channels + Channel.promotable.first(30 - @channels.size)).uniq if @channels.size < 30
  end

  def default_url_options
    # return { channel: @current_channel.slug } unless @current_channel.name == 'default'
    { channel: @current_channel.slug }
  end
end
