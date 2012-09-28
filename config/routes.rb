Nembrot::Application.routes.draw do

	mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

	devise_for :users

	root :to => "home#index"

  get 'notes/:id/v/:sequence' => 'notes#version', :id => /\d+/, :sequence => /\d+/
  get 'notes/:id' => 'notes#show', :id => /\d+/
  get 'tags/:slug' => 'tags#show', :slug => /[\-\w]+/

  get 'notes' => 'notes#index'
  get 'tags' => 'tags#index'

	resources :notes, only: [:index, :show, :version] do
		resources :v, :as => :versions
	end

	resources :tags, only: [:index, :show]

end
