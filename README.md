# Nembrot
[![Build Status](https://travis-ci.org/nembrotorg/nembrot.png?branch=master)][travis]
[![Dependency Status](https://gemnasium.com/nembrotorg/nembrot.png)][gemnasium]
[![Code Climate](https://codeclimate.com/github/nembrotorg/nembrot.png)][codeclimate]
[![Coverage Status](https://coveralls.io/repos/nembrotorg/nembrot/badge.png?branch=master)][coveralls]

[travis]: http://travis-ci.org/nembrotorg/nembrot
[gemnasium]: https://gemnasium.com/nembrotorg/nembrot
[codeclimate]: https://codeclimate.com/github/nembrotorg/nembrot
[![Test Coverage](https://codeclimate.com/github/nembrotorg/nembrot/badges/coverage.svg)](https://codeclimate.com/github/nembrotorg/nembrot)
[coveralls]: https://coveralls.io/r/nembrotorg/nembrot

Nembrot is a complete Rails 4 web application that takes notes from your Evernote notebooks and publishes them online. For more details see [nembrot.org](http:nembrot.org).

[nembrot.org](http:nembrot.org) is actually a vanilla implementation of this code.

A fork of this code is used on the hosted service [nembrot.com](http://nembrot.com).

##Features
* Syncs notes from any [Evernote](http://evernote.com) notebook
* Converts youtube, vimeo and soundcloud links to embedded players
* Embeds maps and organises notes geographically
* Uses a small set of tags for managing displayed notes
* Share links for Facebook, Twitter, GooglePlus
* Detects note language and switches to right-to-left design, if applicable
* Disqus or native comments
* Account sign-in for comments using Facebook, Twitter, GooglePlus, Github, Linkedin, Evernote, or email/password
* Organises notes by tags
* Responsive theme
* Google analytics.

Advanced (beta):
* Marginal annotations
* Diffed note versions
* Bibliography
* Links
* Parallel display of translated notes.


## Getting started
You will need to have Ruby > 2.1 installed on your machine. Clone this code and install the gems.

#### 1. Get the code
```
$ git clone git@github.com:nembrotorg/nembrot.git
$ cd nembrot
$ rake db:migrate
```

#### 2. Get an Evernote account
If you don't already have one, [create an Evernote account](https://www.evernote.com/Registration.action).


#### 3. Get an Evernote API key
Go to [dev.evernote.com](http://dev.evernote.com/doc/) and request a new API key. After you've read everything you need to read, click on the green button at the top right corner. Your API key will need Full access, so choose that option. Nembrot does not synchronise all note data so do not check the box thats says, "This integration will sync all user data".


#### 4. Create Evernote sandbox account
Your API key initially works only on the Evernote sandbox server. If you don't already have a sandbox account, [create one now](https://sandbox.evernote.com/Registration.action). Once you are signed in create a new notebook. Make sure the username you choose is the same as the one you enter in the settings.


#### 5. Change settings
Make a duplicate of config/secret.sample.yml and rename it secret.yml. You will need to provide a value for all the settings that do not end with '_OPTIONAL'.

Duplicate config/channel.settings.sample.yml, rename it to channel.settings.yml and change the value for "notebooks" to the id of your Evernote notebook. To get this go to your Evernote sandbox account and click on the notebook. You will see that the url has changed to something like:

> sandbox.evernote.com/Home.action#b=8a5bc592-8888-49d7-9ad9-7778f9b173dd&st=p

Your notebook id is the value for b in the query string, in this case 8a5bc592-8888-49d7-9ad9-7778f9b173dd.

Similarly, duplicate, rename and edit config/advanced.settings.sample.yml.


#### 6. Start your server
Update the settings default:

    $ rake settings:update_defaults

And finally, you can start your rails server!

    $ rails s


#### 7. Create a Nembrot user account
Click on the user icon at the bottom left of the page, or go to [localhost:3000/users/sign_in](http://localhost:3000/users/sign_in). Sign in using your Evernote sandbox account. Nembrot will detect that the username for this account is the same as the one you entered in secret.yml and give your account an "admin" role.


#### 8. Create your first note
Go back back to the notebook you created on your [Evernote sandbox account](http://sandbox.evernote.com) and create a new note inside it. Add whatever you like as content: text, images, video links. Add a tag with the name **__PUBLISH** (note two underscres). This tells Nembrot to publish your note. Make sure you add at least 300 words or so. (By default, very short notes are not shown on index pages.)


#### 9. Sync your first note
Later on, we will use a webhook to update automatically but in development we will simulate the webhook. On your Evernote sandbox account, click on the note you have just created. The url will change to something like:

> sandbox.evernote.com/Home.action#n=028f4d7e-5ecd-4a82-81ea-0000a7c5d400&st=p

Now go to http://localhost:3000/webhooks/evernote_note?guid=**028f4d7e-5ecd-4a82-81ea-0000a7c5d400**. (Change the value for guid to the one shown for n in the Evernote sandbox url.)

And that's it! Go to [localhost:3000](http://localhost:3000) and you should see your first note on the homepage.


## Going live

For instructions on deploying your site to production, see [Going live](http://nembrot.org/going-live).


## Testing
```
$ rake settings:update_defaults RAILS_ENV=test
$ rake db:test:prepare
$ rspec spec
```

Guard is installed so you can also do:
   bundle exec guard


## Contribute
This is still a relatively new project and there's still a lot to do. All contributions are hugely welcome!

Please report issues on the [issue tracker](https://github.com/nembrotorg/nembrot/issues). 

* Fork the project
* Use a topic/feature branch
* Make sure to add tests for your changes
* Run "rspec spec" and make sure all tests are passing
* Open a [pull request](https://help.github.com/articles/using-pull-requests).


## License
See [LICENSE.txt](https://github.com/nembrotorg/nembrot/blob/master/LICENSE.txt) for details.
