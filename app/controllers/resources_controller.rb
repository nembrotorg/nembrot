class ResourcesController < ApplicationController

  include ResourcesHelper

  skip_before_action :set_locale,
                     :set_current_channel,
                     :set_channel_defaults,
                     :add_home_breadcrumb,
                     :get_promoted_notes,
                     :get_sections,
                     :get_map_all_markers,
                     :set_public_cache_headers

  def download
    file_name = "#{ params[:file_name] }.pdf"
    expires_in 1.year, public: true
    send_file "/resources/raw/#{ file_name }", type: 'application/pdf', filename: file_name
  end

  def cut
    image = cut_image_binary(
        params[:id],
        params[:format],
        params[:aspect_x].to_i,
        params[:aspect_y].to_i,
        params[:width].to_i,
        params[:snap],
        params[:gravity],
        params[:effects]
      )

    expires_in 1.year, public: true
    send_file(image, disposition: 'inline')

    rescue
      redirect_to "/resources/cut/blank.#{ params[:format] }"
  end
end
