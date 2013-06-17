# encoding: utf-8

class DiffedNoteVersion

  attr_accessor :sequence, :title, :body, :tag_list, :previous_body, :previous_title, :previous_tag_list,
                :embeddable_source_url, :external_updated_at

  def initialize(note, sequence)

    versions = note.versions

    if sequence == 1
      version = versions.first.reify
      @previous_title = ''
      @previous_body = ''
      @tag_list = versions.first.tag_list
      @previous_tag_list = []
    elsif sequence == versions.size + 1
      version = note
      previous_version = versions.last.reify
      @previous_title = previous_version.title
      @previous_body = previous_version.body
      @tag_list = version.tag_list
      @previous_tag_list = versions.find_by_sequence(sequence - 1).tag_list
    else
      version = versions.find_by_sequence(sequence).reify
      previous_version = version.previous_version
      @previous_title = previous_version.title
      @previous_body = previous_version.body
      @tag_list = versions.find_by_sequence(sequence).tag_list
      @previous_tag_list = versions.find_by_sequence(sequence - 1).tag_list
    end

    @sequence = sequence
    @title = version.title
    @body = version.body
    @embeddable_source_url = version.embeddable_source_url
    @external_updated_at = version.external_updated_at
  end
end
