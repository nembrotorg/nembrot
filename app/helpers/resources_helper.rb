# encoding: utf-8

module ResourcesHelper

  include EffectsHelper

  # REVIEW: Does this duplicate Resource#cut_location? Or maybe this should be a separate Class?

  def cut_image_binary_path(image, options = {})
    type = options[:type] || 'standard'
    x = options[:aspect_x] || Settings.styling.images[type]['aspect']['x']
    y = options[:aspect_y] || Settings.styling.images[type]['aspect']['y']
    width = options[:width] || Settings.styling.images[type]['width']
    snap = options[:snap] || Settings.styling.images.snap
    gravity = options[:gravity] || Settings.styling.images.gravity
    effects = options[:effects] || image.note.fx
    id = options[:id] || image.id

    Rails.application.routes.url_helpers.cut_resource_path(
      file_name: image.local_file_name,
      aspect_x: x,
      aspect_y: y,
      width: width,
      snap: snap,
      gravity: gravity,
      effects: effects,
      id: id,
      format: image.file_ext.to_sym
    )
  end

  def cut_image_binary(local_file_name, format, aspect_x, aspect_y, width, snap, gravity, effects)
    # TODO: add gravity
    image_record = Resource.find_by_local_file_name(local_file_name)

    if image_record.nil?
      logger.info t('resources.cut.failed.record_not_found', local_file_name: local_file_name)
      return Settings.images.default_blank_location
    end

    file_name_template = image_record.template_location(aspect_x, aspect_y)
    file_name_out = image_record.cut_location(aspect_x, aspect_y, width, snap, gravity, effects)

    # Shorthand: small integers are taken to be number of columns rather than absolute width 
    width = column_width(width) if width <= Settings.styling.columns

    # The height is derived from the aspect ratio and width.
    height = (width * aspect_y) / aspect_x

    # We snap the height to nearest baseline to maintain a vertical grid.
    height = round_nearest(height, Settings.styling.line_height) if snap == 1

    # We check if a (manually-cropped) template exists.
    file_name_in = (File.exists?(file_name_template) ? file_name_template : image_record.raw_location)

    begin
      image =  MiniMagick::Image.open(file_name_in)
      image = pre_fx(image, effects)

      # TODO: This needs to do crop/resize, not just resize.
      image.resize "#{ width }x#{ height }"

      image = fx(image, effects)
      image = post_fx(image, effects, image_record)

      # Gravity
      # image = image.resize_to_fit(width, height, EastGravity)

      # We save the image so next time it can be served directly, totally bypassing Rails.
      image.write file_name_out
      return file_name_out
    rescue => error
      image_record.dirty = true
      image_record.save!
      logger.info t('resources.cut.failed.image_record_not_found', local_file_name: local_file_name)
      logger.info error
      return image_record.blank_location
    end
  end

  private

  def round_nearest(number, nearest)
    (number / nearest.to_f).round * nearest
  end

  def column_width(columns)
    (Settings.styling.column_width * columns) + (Settings.styling.gutter_width * (columns - 1))
  end
end
