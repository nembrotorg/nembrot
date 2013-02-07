Nembrot::Application.routes.draw do

	mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

	devise_for :users

	root :to => 'home#index'

  match 'auth/failure' => 'cloud_services#auth_failure'
  match 'auth/:provider/callback' => 'cloud_services#auth_callback'

  get 'webhooks/evernote_note' => 'cloud_notes#update_cloud'

  get 'notes/:id/v/:sequence' => 'notes#version', :id => /\d+/, :sequence => /\d+/, :as => :note_version
  get 'notes/:id' => 'notes#show', :id => /\d+/, :as => :note
  get 'notes/map' => 'notes#map'
  get 'notes' => 'notes#index'

  get 'tags/:slug/map' => 'tags#map', :slug => /[\_a-z\d\-]+/, :as => :tag_map
  get 'tags/:slug' => 'tags#show', :slug => /[\_a-z\d\-]+/, :as => :tag
  get 'tags' => 'tags#index'

  # Redirect downloads though they should never reash here

  get 'resources/cut/(:file_name)-(:aspect_x)-(:aspect_y)-(:width)-(:snap)-(:gravity)-(:effects)' => 'resources#cut',
    :as => :cut_resource,
    :aspect_x => /\d+/,
    :aspect_y => /\d+/,
    :width => /\d+/,
    :snap => /[01]/,
    :gravity => /0|c|n|ne|w|se|s|sw|w|nw/,
    :constraints => {:format => /(gif|jpg|jpeg|png)/}

  resources :cloud_notes, only: [:update_cloud]

  resources :cloud_services, only: [:auth_callback, :auth_failure]
end
