Nembrot::Application.routes.draw do

	mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

	devise_for :users

	root :to => 'home#index'

  match 'auth/failure', to: 'cloud_services#auth_failure'
  match 'auth/:provider/callback', to: 'cloud_services#auth_callback'


  get 'auth/:provider/inspect' => 'cloud_services#auth_inspect'

  get 'webhooks/evernote_note' => 'cloud_notes#update_cloud'

  get 'notes/:id/v/:sequence' => 'notes#version', :id => /\d+/, :sequence => /\d+/
  get 'notes/:id' => 'notes#show', :id => /\d+/

  get 'tags/:slug' => 'tags#show', :slug => /[a-z\d\-]+/

  resources :notes, only: [:index, :show, :version] do
    resources :v, :as => :versions
  end

  resources :tags, only: [:index, :show]

  resources :cloud_notes, only: [:update_cloud]

  resources :cloud_services, only: [:auth_callback, :auth_failure]
end
