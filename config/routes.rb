Nembrot::Application.routes.draw do

	mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

	devise_for :users

	root :to => 'home#index'

  match 'auth/failure' => 'evernote_auths#auth_failure'
  match 'auth/:provider/callback' => 'evernote_auths#auth_callback'

  get 'webhooks/evernote_note' => 'evernote_notes#add_task'

  get 'notes/:id/v/:sequence' => 'notes#version', :id => /\d+/, :sequence => /\d+/, :as => :note_version
  get 'notes/:id' => 'notes#show', :id => /\d+/, :as => :note
  get 'notes/map' => 'notes#map'
  get 'notes' => 'notes#index'

  get 'tags/:slug/map' => 'tags#map', :slug => /[\_a-z\d\-]+/, :as => :tag_map
  get 'tags/:slug' => 'tags#show', :slug => /[\_a-z\d\-]+/, :as => :tag
  get 'tags' => 'tags#index'

  get 'bibliography/:slug' => 'books#show', :slug => /[\_a-z\d\-]+/, :as => :book
  get 'bibliography' => 'books#index', :as => :books

  get 'resources/cut/(:file_name)-(:aspect_x)-(:aspect_y)-(:width)-(:snap)-(:gravity)-(:effects)-(:id)' => 'resources#cut',
    :as => :cut_resource,
    :aspect_x => /\d+/,
    :aspect_y => /\d+/,
    :width => /\d+/,
    :snap => /[01]/,
    :gravity => /0|c|n|ne|w|se|s|sw|w|nw/,
    :constraints => { :format => /(gif|jpg|jpeg|png)/ }

  resources :evernote_notes, only: [:add_evernote_task]

  resources :evernote_auths, only: [:auth_callback, :auth_failure]
end
