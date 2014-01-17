# encoding: utf-8

Nembrot::Application.routes.draw do

  mount Commontator::Engine => '/commontator'

  devise_for :users, controllers: { registrations: 'registrations', sessions: 'sessions', omniauth_callbacks: 'omniauth_callbacks' }

  get ':channel' => 'home#index'
  root to: 'home#index'

  resources :channels

  get 'users/menu' => 'users#menu'

  devise_scope :user do
    get 'users/event/:event' => 'devise/sessions#event', as: :user_event
  end

  get 'webhooks/evernote_note' => 'evernote_notes#add_task'
  resources :evernote_notes, only: [:add_evernote_task]

  get 'settings/reset/:namespace' => 'settings#reset', as: :reset_settings, namespace: /channel|advanced|style/
  put 'settings' => 'settings#update', as: :update_settings
  get 'settings/edit' => 'settings#edit', as: :edit_settings

  get 'resources/cut/(:file_name)-(:aspect_x)-(:aspect_y)-(:width)-(:snap)-(:gravity)-(:effects)-(:id)' => 'resources#cut',
    as: :cut_resource,
    aspect_x: /\d+/,
    aspect_y: /\d+/,
    width: /\d+/,
    snap: /[01]/,
    gravity: /0|north_west|north|north_east|east|south_east|south|south_west|west|center/,
    constraints: { format: /(gif|jpg|jpeg|png)/ }

  scope ':channel' do
    put 'bibliography/update' => 'books#update', as: :update_book
    get 'bibliography/:id/edit' => 'books#edit', as: :edit_book
    get 'bibliography/admin(/:mode)' => 'books#admin', as: :books_admin, mode: /|editable|citable|cited|missing_metadata/
    get 'bibliography/:slug' => 'books#show', slug: /[\_a-z\d\-]+/, as: :book
    get 'bibliography(/p/:page)' => 'books#index', as: :books

    get 'citations/:id' => 'citations#show', id: /\d+/, as: :citation
    get 'citations(/p/:page)' => 'citations#index', as: :citations

    put 'links/update' => 'links#update', as: :update_link
    get 'links/admin' => 'links#admin', as: :links_admin
    get 'links/:id/edit' => 'links#edit', as: :edit_link
    get 'links/:slug' => 'links#show_channel', slug: /[\_a-z\d\-\.]+/, as: :link
    get 'links(/p/:page)' => 'links#index', as: :links

    get 'notes/:id/v/:sequence' => 'notes#version', id: /\d+/, sequence: /\d+/, as: :note_version
    get 'notes/:id' => 'notes#show', id: /\d+/, as: :note
    get 'notes/map' => 'notes#map'
    get 'notes/p/:page' => 'notes#index'
    get 'notes' => 'notes#index', as: :notes

    get 'tags/:slug/map' => 'tags#map', slug: /[\_a-z\d\-]+/, as: :tag_map
    get 'tags/:slug' => 'tags#show', slug: /[\_a-z\d\-]+/, as: :tag
    get 'tags(/p/:page)' => 'tags#index', as: :tags

    get ':feature(/:feature_id)/v/:sequence' => 'features#show', feature: /[\_a-z\d\-]+/, feature_id: /[\_a-z\d\-]+/, sequence: /\d+/, as: :feature_version
    get ':feature(/:feature_id)' => 'features#show', feature: /[\_a-z\d\-]+/, feature_id: /[\_a-z\d\-]+/, as: :feature
  end
end
