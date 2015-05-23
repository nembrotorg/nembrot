# encoding: utf-8

class DiffedNoteVersion
  attr_accessor :sequence, :title, :body, :tag_list, :previous_body, :previous_title, :previous_tag_list,
                :is_embeddable_source_url, :external_updated_at

  def initialize(note, sequence)
    versions = note.versions

    if sequence == 1
      version = versions.first.reify
      self.previous_title = ''
      self.previous_body = ''
      self.tag_list = versions.first.tag_list['internal']
      self.previous_tag_list = []
    elsif sequence == versions.size + 1
      version = note
      previous_version = versions.last.reify
      self.previous_title = previous_version.title
      self.previous_body = previous_version.body
      self.tag_list = version.tag_list
      self.previous_tag_list = versions.find_by_sequence(sequence - 1).tag_list['internal']
    else
      version = versions.find_by_sequence(sequence).reify
      previous_version = version.previous_version
      self.previous_title = previous_version.title
      self.previous_body = previous_version.body
      self.tag_list = versions.find_by_sequence(sequence).tag_list['internal']
      self.previous_tag_list = versions.find_by_sequence(sequence - 1).tag_list['internal']
    end

    self.sequence = sequence
    self.title = version.title
    self.body = version.body
    self.is_embeddable_source_url = version.is_embeddable_source_url
    self.external_updated_at = version.external_updated_at
  end
end
