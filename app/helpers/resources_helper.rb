module ResourcesHelper

  require 'RMagick'
  include Magick

  def cut_image(raw_image, format, aspect_x, aspect_y, width, snap, gravity, effects)
    # Need to add gravity, snap, effects
    # need to add ability to handle all formats - what do we do with pdf/audio/video (we should not download audio/video)?
    file_name_template = File.join(Rails.root, 'public', 'resources', 'cropped', "#{ raw_image }-#{ aspect_x }-#{ aspect_y }.#{ format }")
    file_name_out = File.join(Rails.root, 'public', 'resources', 'cut', "#{ raw_image }-#{ aspect_x }-#{ aspect_y }-#{ width }.#{ format }")

    # The height is derived from the aspect ratio and width.
    height = (width * aspect_y) / aspect_x

    if snap
      # We snap the height to nearest baseline to maintain a vertical grid.
      height = round_nearest(height, Settings.styling.lineheight)
    end

    # We check if a (manually-cropped) template exists.
    if File.file?(file_name_template)
      file_name_in = file_name_template
    else
      # If file doesn't exist we should mark Resource as dirty and send pixel (but not save it)
      file_name_in = File.join(Rails.root, 'public', 'resources', 'raw', raw_image + '.' + format)
    end

    begin
      image =  Magick::Image.read(file_name_in).first
      image = image.crop_resized(width, height)
      # We save the image so next time it can be served directly,
      # totally bypassing Rails.
      image.write(file_name_out)
      file_name_out
    rescue
      res = Resource.find_by_file_name(raw_image + '.' + format)
      res.dirty = true
      res.save
      # log info (Raw image not found)
      # else blank_pixel_here from settings
    else
      # log info (Resource record not found)
      # else blank_pixel_here from settings      
    end
  end

  def effects_image(raw_image, effects)
  end

  def round_nearest(number, nearest)
    (number / nearest.to_f).round * nearest
  end
end
