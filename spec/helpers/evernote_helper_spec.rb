require 'spec_helper'

describe EvernoteHelper do

  before {

    require 'webmock/rspec'

    WebMock.disable_net_connect!

    stub_request(:post, "https://sandbox.evernote.com/shard/s1/notestore").
      with(:body => /^.*getNote.*$/).
      to_return(:status => 200, :body => File.new(File.join(Rails.root, 'spec', 'webmocks', 'evernote_note_data.txt')), :headers => {})

    stub_request(:post, "https://sandbox.evernote.com/shard/s1/notestore").
      with(:body => /^.*getTagNames.*$/).
      to_return(:status => 200, :body => File.new(File.join(Rails.root, 'spec', 'webmocks', 'evernote_tag_names.txt')), :headers => {})

    stub_request(:post, "https://sandbox.evernote.com/shard/s1/notestore").
      with(:body => /^.*getResourceData.*$/).
      to_return(:status => 200, :body => File.new(File.join(Rails.root, 'spec', 'webmocks', 'evernote_resource_data.txt')), :headers => {})

  }

  describe "add_evernote_tasks" do
    before {
      add_evernote_task('ABC200', false)      
    }
    it "should add a CloudNote when requested" do
      CloudNote.last.cloud_note_identifier.should == 'ABC200'
    end
    it "should mark new CloudNote as dirty" do
      CloudNote.last.dirty.should == true
    end
  end

  describe "add_evernote_tasks" do
    before {
      add_evernote_task('ABC200', true)      
    }
    it "should request authentication of cloud service" do
      CloudNote.last.cloud_note_identifier.should == 'ABC200'
    end
    it "should mark new CloudNote as dirty" do
      CloudNote.last.dirty.should == true
    end
  end

  describe "run_evernote_tasks" do
    it "should add a dirty CloudNote when requested" do
    end
  end

  describe "syncdown_note" do
    it "should send an admin email if auth is absent" do
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
