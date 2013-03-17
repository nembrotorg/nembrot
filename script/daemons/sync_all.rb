require ENV["RAILS_ENV_PATH"]

loop { 

  EvernoteNote.sync_all
  Resource.sync_all_binaries
  sleep(5)

}
