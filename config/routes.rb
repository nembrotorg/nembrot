Nembrot::Application.routes.draw do

	mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

	devise_for :users

	root :to => 'home#index'

  match 'auth/failure' => 'cloud_services#auth_failure'
  match 'auth/:provider/callback' => 'cloud_services#auth_callback'

  get 'webhooks/evernote_note' => 'cloud_notes#update_cloud'

  get 'notes/:id/v/:sequence' => 'notes#version', :id => /\d+/, :sequence => /\d+/, :as => :note_version
  get 'notes/:id' => 'notes#show', :id => /\d+/, :as => :note
  get 'notes' => 'notes#index'

  get 'tags/:slug' => 'tags#show', :slug => /[\_a-z\d\-]+/, :as => :tag
  get 'tags' => 'tags#index'

  get 'resources/raw/:cloud_resource_identifier' => 'resources#raw', :as => :raw_resource

  resources :cloud_notes, only: [:update_cloud]

  resources :cloud_services, only: [:auth_callback, :auth_failure]
end
