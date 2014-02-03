class HomeController < ApplicationController

  def index
    @all_interrelated_notes_and_features = Note.channelled(@current_channel).interrelated.publishable.notes_and_features
    @all_interrelated_citations = Note.channelled(@current_channel).interrelated.publishable.citations

    @note = Note.channelled(@current_channel).publishable.homeable.first
    # REVIEW: This could go in the Note model as part of channelled
    #  However, channelled would need to be a scope so that it returns an ActiveRecord
    #  relation rather than an array.
    @note = @default_note if @note.nil?

    interrelated_notes_features_and_citations
    note_tags(@note)
    note_map(@note)
    note_source(@note)

    # REVIEW: These are decalred twice!
    set_channel_defaults
    add_home_breadcrumb
    get_promoted_notes(@note)
    get_sections

    @channels = Channel.not_owned_by_nembrot.first(9)
  end

  def default_url_options
    # return { channel: @current_channel.slug } unless @current_channel.name == 'default'
    { channel: @current_channel.slug }
  end
end
