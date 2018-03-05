Rails.application.routes.draw do
  root 'home#index'
  get 'home/index'

  get 'home/view'

  get 'home/list'
  post 'home/list'

  post 'home/users'

  get 'home/view/:id' => 'home#view'
  post 'home/view/:id' => 'home#view'

  post 'home/save_pdf/:id' => 'home#save_pdf'

  post 'home/out'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
