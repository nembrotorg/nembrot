require 'spec_helper'

describe EvernoteHelper do

  describe "run_evernote_tasks" do
    it "should add a dirty CloudNote when requested" do
      # Also do this in requests
      add_evernote_task('ABC200')
      CloudNote.needs_syncdown.last.external_note_identifier = 'ABC200'
    end
  end

  describe "syncdown_note" do
    it "should..." do
      # xx
    end
  end

  describe "get_note_store" do
    it "should..." do
      # xx
    end
  end

  describe "create_or_update_note" do
    it "should..." do
      # xx
    end
  end

  describe "check_version" do
    it "should..." do
      # xx
    end
  end
end
