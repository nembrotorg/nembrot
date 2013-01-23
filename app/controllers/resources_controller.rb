class ResourcesController < ApplicationController

  include ResourcesHelper

  def cut
    image = cut_image(
        params[:file_name],
        params[:format],
        params[:aspect_x].to_i,
        params[:aspect_y].to_i,
        params[:width].to_i,
        true,
        '',
        ''
      )

    send_file(image, :disposition => 'inline')
  end
end
