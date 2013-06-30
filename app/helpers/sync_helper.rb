# encoding: utf-8

module SyncHelper
  def text_for_instructions(text = body)
    ActionController::Base.helpers.strip_tags(text).gsub(/\n\n*\r*/, '\n').strip
  end

  def text_for_analysis(text = body)
    text_for_instructions(text).gsub(/^\w*?\:.*$/, '')
  end

 def lang_from_cloud(content = text_for_analysis)
    response = content[0..Settings.notes.wtf_sample_length].lang
    Array(response.match(/^\w\w$/)).size == 1 ? response : nil
  end

  def has_instruction?(instruction, instructions = instruction_list)
    !((Settings.notes.instructions.default + instructions) & Settings.notes.instructions[instruction]).empty?
  end

  def looks_like_a_citation?(content = text_for_analysis)
    # OPTIMIZE: Replace 'quote': by i18n
    content.scan(/\A\W*quote\:(.*?)\n?\-\- *?(.*?[\d]{4}.*)\W*\Z/).size == 1
  end

  def word_count(content = text_for_analysis)
    content.split.size
  end

  def dirtify(save_it = true)
    self.dirty = true
    self.attempts = 0
    self.save! if save_it
  end

  def undirtify(save_it = true)
    self.dirty = false
    self.attempts = 0
    self.save! if save_it
  end

  def increment_attempts
    self.increment!(:attempts)
  end

  def max_out_attempts
    self.update_attributes!(attempts: Settings.notes.attempts + 1)
  end

  def merge(new_values, overwrite = false, object = self)
    new_values.each do |key, value|
      value.strip! if value.is_a? String
      object.send("#{ key }=", value) if !value.nil? && (object.send("#{ key }").nil? || overwrite)
    end unless new_values.blank?
  end
end
