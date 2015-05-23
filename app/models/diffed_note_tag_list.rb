# encoding: utf-8

class DiffedNoteTagList
  attr_accessor :list

  def initialize(previous_tag_list, tag_list)
    added_tags = (tag_list - previous_tag_list)
    removed_tags = (previous_tag_list - tag_list)
    unchanged_tags = (tag_list - added_tags - removed_tags)

    diffed_tag_list = {}

    added_tags.each do |tag|
      diffed_tag_list[tag] = {
        'status' => 1,
        'obsolete' => is_obsolete?(tag)
      }
    end

    removed_tags.each do |tag|
      diffed_tag_list[tag] = {
        'status' => -1,
        'obsolete' => is_obsolete?(tag)
      }
    end

    unchanged_tags.each do |tag|
      diffed_tag_list[tag] = {
        'status' => 0,
        'obsolete' => is_obsolete?(tag)
      }
    end

    self.list = Hash[diffed_tag_list.sort]
  end

  def is_obsolete?(tag)
    (Note.tagged_with(tag).size == 0)
  end
end
