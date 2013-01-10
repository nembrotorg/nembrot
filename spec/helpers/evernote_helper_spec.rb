describe EvernoteHelper do

  describe "add_evernote_tasks" do
    before {
      add_evernote_task('ABC100', false)   
    }
    it "should add a CloudNote when requested" do
      CloudNote.last.cloud_note_identifier.should == 'ABC100'
    end
    it "should mark new CloudNote as dirty" do
      CloudNote.last.dirty.should == true
    end
  end

  describe "run_evernote_tasks for the first time (cloud_service not authenticated)" do
    before {
      @cloud_service = FactoryGirl.create(:cloud_service, :name => 'evernote', :auth => nil)
      add_evernote_task('ABC200', true)      
    }
    it "should request authentication of cloud service" do
      ActionMailer::Base.deliveries.last.subject.should == 'Evernote authentication required'
    end
  end

  describe "run_evernote_tasks should syncdown pending notes" do
    before {
    }
    it "should de-activate a note that is not in a required notebook" do
      # xxx
    end
    it "should de-activate a note that has been deleted in the cloud notebook" do
      # xxx
    end
    it "should de-activate a note not tagged with __PUBLISH (or synonyms)" do
      # xxx
    end
    it "should not update a note tagged with __IGNORE (or synonyms)" do
      # xxx
    end
    it "should not request full data if content hash has not changed" do
      # xxx
    end
    it "should request full data if content hash has changed" do
      # xxx
    end
    it "should syncdown resource if it has changed" do
      # xxx
    end
  end
end
