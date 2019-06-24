# encoding: utf-8

module ResourcesHelper
  include EffectsHelper

  # REVIEW: Does this duplicate Resource#cut_location? Or maybe this should be a separate Class?
  #  Derive from: https://github.com/carrierwaveuploader/carrierwave/blob/92c817bb7b1c821d8021d3fd1ded06551b1d9a01/lib/carrierwave/processing/mini_magick.rb
  #  And: https://gist.github.com/tonycoco/2910540

  def cut_image_binary_path(image, options = {})
    type = options[:type] || 'standard'

    Rails.application.routes.url_helpers.cut_resource_path(
      file_name:  image.local_file_name,
      aspect_x:   options[:aspect_x]  || ENV["images_#{ type }_aspect_x"].to_i,
      aspect_y:   options[:aspect_y]  || ENV["images_#{ type }_aspect_y"].to_i,
      width:      options[:width]     || ENV["images_#{ type }_width"].to_i,
      snap:       options[:snap]      || NB.images_snap,
      gravity:    options[:gravity]   || NB.images_gravity,
      effects:    options[:effects]   || image.note.fx,
      id:         options[:id]        || image.id,
      format:     image.file_ext.to_sym
    )
  end

  def cut_image_binary(id, _format, aspect_x, aspect_y, width, snap, gravity, effects)
    image_record = Resource.find(id)

    file_name_template = image_record.template_location(aspect_x, aspect_y)
    file_name_out = image_record.cut_location(aspect_x, aspect_y, width, snap, gravity, effects)

    # The height is derived from the aspect ratio and width.
    height = (width * aspect_y) / aspect_x

    # We snap the height to nearest baseline to maintain a vertical grid.
    height = round_nearest(height, NB.line_height.to_i) if snap == '1'

    larger_cut_image_with_effects =  image_record.larger_cut_image_location(aspect_x, aspect_y, width, snap, gravity, effects, NB.total_columns.to_i)
    larger_cut_image_without_effects =  image_record.larger_cut_image_location(aspect_x, aspect_y, width, snap, gravity, '', NB.total_columns.to_i)

    template_already_has_effects = false

    if !larger_cut_image_with_effects.nil?
      template_already_has_effects = true
      file_name_in = larger_cut_image_with_effects
    elsif !larger_cut_image_without_effects.nil?
      file_name_in = larger_cut_image_without_effects
    elsif File.exist?(file_name_template)
      file_name_in = file_name_template
    else
      file_name_in = image_record.raw_location
    end

    image =  MiniMagick::Image.open(file_name_in)
    image = resize_with_crop(image, width, height, gravity_options = {})
    image.write file_name_out

    unless template_already_has_effects
      # REVIEW: Here we re-open the image - this must slow things down
      image = MiniMagick::Image.new(file_name_out)
      pre_fx(image, effects)

      # TODO: This needs to do crop/resize, not just resize.
      # image.resize "#{ width }x#{ height }"

      # Gravity
      # image = image.resize_to_fit(width, height, EastGravity)
      # gravity_options = { gravity: gravity } unless gravity == '0' || gravity == ''
      # resize_with_crop(image, width, height, gravity_options = {})

      fx(image, effects)
      post_fx(image, effects)
    end

    # TODO: Test for speed
    # image_optim = ImageOptim.new
    # image_optim.optimize_image!(file_name_out)

    # We save the image so next time it can be served directly, totally bypassing Rails.
    # image.write file_name_out
    return file_name_out
  rescue => error
    if image_record
      image_record.dirty = true
      image_record.save!
    end
    logger.info t('resources.cut.failed.image_record_not_found', id: id)
    logger.info error
    return Resource.blank_location
  end

  def round_nearest(number, nearest)
    (number / nearest.to_f).round * nearest
  end

  # FROM: http://maxivak.com/crop-and-resize-an-image-using-minimagick-ruby-on-rails/
  def resize_with_crop(img, w, h, options = {})
    gravity = options[:gravity] || :center

    w_original = img[:width].to_f
    h_original = img[:height].to_f

    op_resize = ''

    # check proportions
    if w_original * h < h_original * w
      op_resize = "#{ w.to_i }x"
      w_result = w
      h_result = (h_original * w / w_original)
    else
      op_resize = "x#{ h.to_i }"
      w_result = (w_original * h / h_original)
      h_result = h
    end

    w_offset, h_offset = crop_offsets_by_gravity(gravity, [w_result, h_result], [w, h])

    img.combine_options do |i|
      i.resize(op_resize)
      i.gravity(gravity)
      i.crop "#{w.to_i}x#{h.to_i}+#{w_offset}+#{h_offset}!"
      i.quality 65
    end

    img
  end

  # from http://www.dweebd.com/ruby/resizing-and-cropping-images-to-fixed-dimensions/

  GRAVITY_TYPES = [:north_west, :north, :north_east, :east, :south_east, :south, :south_west, :west, :center]

  def crop_offsets_by_gravity(gravity, original_dimensions, cropped_dimensions)
    fail(ArgumentError, "Gravity must be one of #{GRAVITY_TYPES.inspect}") unless GRAVITY_TYPES.include?(gravity.to_sym)
    fail(ArgumentError, 'Original dimensions must be supplied as a [ width, height ] array') unless original_dimensions.is_a?(Enumerable) && original_dimensions.size == 2
    fail(ArgumentError, 'Cropped dimensions must be supplied as a [ width, height ] array') unless cropped_dimensions.is_a?(Enumerable) && cropped_dimensions.size == 2

    original_width, original_height = original_dimensions
    cropped_width, cropped_height = cropped_dimensions

    [
      _horizontal_offset(gravity, original_width, cropped_width),
      _vertical_offset(gravity, original_height, cropped_height)
    ]
  end

  def _horizontal_offset(gravity, original_width, cropped_width)
    case gravity
    when :north_west, :west, :south_west then 0
    when :center, :north, :south then [((original_width - cropped_width) / 2.0).to_i, 0].max
    when :north_east, :east, :south_east then (original_width - cropped_width).to_i
    end
  end

  def _vertical_offset(gravity, original_height, cropped_height)
    case gravity
    when :north_west, :north, :north_east then 0
    when :center, :east, :west then [((original_height - cropped_height) / 2.0).to_i, 0].max
    when :south_west, :south, :south_east then (original_height - cropped_height).to_i
    end
  end
end
