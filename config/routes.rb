# encoding: utf-8

Nembrot::Application.routes.draw do

  mount Commontator::Engine => '/commontator'

  devise_for :users, controllers: { registrations: 'registrations', sessions: 'sessions', omniauth_callbacks: 'omniauth_callbacks' }

  root to: 'home#index'

  get 'code/:controller_script/:action_script' => 'code#show'

  put 'bibliography/update' => 'books#update', as: :update_book
  get 'bibliography/:id/edit' => 'books#edit', as: :edit_book
  get 'bibliography/admin(/:mode)' => 'books#admin', as: :books_admin, mode: /|editable|citable|cited|missing_metadata/
  get 'bibliography/:slug' => 'books#show', slug: /[\_a-z\d\-]+/, as: :book
  get 'bibliography(/p/:page)' => 'books#index', as: :books

  get 'citations/:id' => 'citations#show', id: /\d+/, as: :citation
  get 'citations(/p/:page)' => 'citations#index', as: :citations

  get 'colophon' => 'colophon#index', as: :colophon

  get 'links(/:tab)(/p/:page)' => 'links#index', as: :links

  get 'texts/:id/v/:sequence' => 'notes#version', id: /\d+/, sequence: /\d+/, as: :note_version
  get 'texts/:id' => 'notes#show', id: /\d+/, as: :note
  get 'texts/map' => 'notes#map', as: :notes_map
  get 'texts/p/:page' => 'notes#index'
  get 'texts' => 'notes#index', as: :notes

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

  get 'tags/:slug/map' => 'tags#map', slug: /[\_a-z\d\-]+/, as: :tag_map
  get 'tags/:slug' => 'tags#show', slug: /[\_a-z\d\-]+/, as: :tag
  get 'tags(/p/:page)' => 'tags#index', as: :tags

  devise_scope :user do
    get 'users/event/:event' => 'devise/sessions#event', as: :user_event
  end

  get 'users/menu' => 'users#menu'

  get 'webhooks/evernote_note' => 'evernote_notes#add_task'

  resources :evernote_notes, only: [:add_evernote_task]

  # Custom routes
  # get 'pantography/v/:sequence' => 'notes#version', id: /\d+/, sequence: /\d+/, as: :note_version
  get 'pantography/:text' => 'pantographs#show', as: :pantograph # , text: /[a-zA-F0-9\%]+/
  get 'pantography' => 'pantographs#index', as: :pantographs

  get ':feature(/:feature_id)/v/:sequence' => 'features#show', feature: /[\_a-z\d\-]+/, feature_id: /[\_a-z\d\-]+/, sequence: /\d+/, as: :feature_version
  get ':feature(/:feature_id)' => 'features#show', feature: /[\_a-z\d\-]+/, feature_id: /[\_a-z\d\-]+/, as: :feature
end
