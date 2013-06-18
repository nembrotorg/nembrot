class ResourcesController < ApplicationController

  include ResourcesHelper

  def cut
    image = cut_image_binary(
        params[:file_name],
        params[:format],
        params[:aspect_x].to_i,
        params[:aspect_y].to_i,
        params[:width].to_i,
        params[:snap],
        params[:gravity],
        params[:effects]
      )

    send_file(image, :disposition => 'inline')
    rescue
      redirect_to "/resources/cut/blank.#{ params[:format]}"
  end
end
