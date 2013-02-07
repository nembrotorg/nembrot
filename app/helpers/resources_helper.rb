module ResourcesHelper

  require 'RMagick'
  include Magick
  include EffectsHelper

  def cut_image_path(image, options = {})
    type = options[:type] || 'standard'
    x = options[:aspect_x] || Settings.styling.images[type]['aspect']['x']
    y = options[:aspect_y] || Settings.styling.images[type]['aspect']['y']
    width = options[:width] || Settings.styling.images[type]['width']
    snap = options[:snap] || Settings.styling.images.snap
    gravity = options[:gravity] || Settings.styling.images.gravity
    effects = options[:effects] || image.note.fx  || Settings.styling.images.effects

    cut_resource_path(
      :file_name => image.local_file_name,
      :aspect_x => x,
      :aspect_y => y,
      :width => width,
      :snap => snap,
      :gravity => gravity,
      :effects => effects,
      :format => image.file_ext.to_sym
    )
  end

  def cut_image(local_file_name, format, aspect_x, aspect_y, width, snap, gravity, effects)
    # Need to add gravity
    image_record = Resource.find_by_local_file_name(local_file_name)

    file_name_template = image_record.template_location(aspect_x, aspect_y)
    file_name_out = image_record.cut_location(aspect_x, aspect_y, width, snap, gravity, effects)

    # The height is derived from the aspect ratio and width.
    height = (width * aspect_y) / aspect_x

    if snap == 1
      # We snap the height to nearest baseline to maintain a vertical grid.
      height = round_nearest(height, Settings.styling.line_height)
    end

    # We check if a (manually-cropped) template exists.
    if File.file?(file_name_template)
      file_name_in = file_name_template
    elsif image_record
      file_name_in = image_record.raw_location
    else
      logger.info t('resources.cut.failed.record_not_found', :local_file_name => local_file_name)
      return image_record.blank_location
    end

    begin
      image =  Magick::Image.read(file_name_in).first

      image = pre_fx(image, effects)

      # Resize image
      image = image.crop_resized(width, height)

      image = fx(image, effects)
      image = post_fx(image, effects, image_record)

      # Gravity
      #image = image.resize_to_fit(width, height, EastGravity)

      # We save the image so next time it can be served directly, totally bypassing Rails.
      image.write(file_name_out)
      return file_name_out
    rescue => error
      image_record.dirty = true
      image_record.save!
      logger.info t('resources.cut.failed.image_record_not_found', :local_file_name => local_file_name)
      logger.info error
      return image_record.blank_location
    else
      logger.info t('resources.cut.failed.record_not_found', :local_file_name => local_file_name)
      logger.info error
      return image_record.blank_location
    end
  end

  private
    def round_nearest(number, nearest)
      (number / nearest.to_f).round * nearest
    end
end
