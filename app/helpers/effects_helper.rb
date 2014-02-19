# encoding: utf-8

module EffectsHelper

  def fx(image, effects)
    cycle_effects('fx', image, effects)
  end

  def pre_fx(image, effects)
    cycle_effects('pre_fx', image, effects)
  end

  def cycle_effects(effect_type, image, effects)
    effects = effects.split(/\|/) if effects.is_a? String
    Array(effects).flatten.each do |effect|
      effect_method = "#{ effect_type }_#{ effect.gsub(/\_|fx|\|/, '') }"
      begin
        image = send(effect_method, image) # unless effect_method.nil?
      rescue
        logger.warn "#{ effect_method } does not exist."
      end
    end
    image
  end

  def pre_fx_lef(image)
    image.transpose
  end

  def pre_fx_rig(image)
    image.transverse
  end

  def pre_fx_tri(image)
    image.trim
  end

  def fx_cha(image)
    image.charcoal
  end

  def fx_duo(image)
    image.duotone
  end

  def fx_red(image)
    image.fill 'red'
    image.colorize '50% 25% 50%'
  end

  def fx_gre(image)
    image.fill 'green'
    image.colorize '25% 50% 25%'
  end

  def fx_grn(image)
    fx_gre(image)
  end

  def fx_blu(image)
    image.fill 'blue'
    image.colorize '25% 25% 50%'
  end

  def fx_enh(image)
    image.enhance
  end

  def fx_equ(image)
    image.equalize
  end

  def fx_fli(image)
    image.flip
  end

  def fx_flo(image)
    image.flop
  end

  def fx_gau(image)
    image.gaussian_blur '0, 1'
  end

  def fx_exp(image)
    image.implode '-0.75'
  end

  def fx_imp(image)
    image.implode '-0.75'
  end

  def fx_mod(image)
    image.modulate '0.85'
  end

  def fx_mot(image)
    image.motion_blur '0, 7, 180'
  end

  def fx_neg(image)
    image.negate
  end

  def fx_nor(image)
    image.normalize
  end

  def fx_rad(image)
    image.radial_blur '5'
  end

  def fx_seg(image)
    image.segment(Magick::YUVColorspace, 0.4, 0.4)
  end

  def fx_sep(image)
    image.sepiatone 'Magick::QuantumRange * 0.8'
  end

  def fx_sha(image)
    image.shade(true, 50, 50)
  end

  def fx_swi(image)
    image.swirl '180'
  end

  def fx_strip(image)
    image.strip
  end

  # From: https://gist.github.com/tonycoco/2910540
  def fx_lomo(image)
    image.combine_options do |c|
      c.channel 'R'
      c.level '22%'
      c.channel 'G'
      c.level '22%'
    end
  end

  def fx_toaster(image)
    image.combine_options do |c|
      c.modulate '150,80,100'
      c.gamma 1.1
      c.contrast
      c.contrast
      c.contrast
      c.contrast
    end
  end

  def fx_kelvin(image)
    image.combine_options do |c|
      cols, rows = image[:dimensions]
       
      c.combine_options do |cmd|
        cmd.auto_gamma
        cmd.modulate '120,50,100'
      end
       
      new_image = image.clone
      new_image.combine_options do |cmd|
        cmd.fill 'rgba(255,153,0,0.5)'
        cmd.draw "rectangle 0,0 #{ cols },#{ rows }"
      end
       
      image = image.composite new_image do |cmd|
        cmd.compose 'multiply'
      end
    end
    image
  end

  def fx_sketch(image)
    sketch = image.quantize(256, Magick::GRAYColorspace)
    sketch = sketch.equalize
    sketch = sketch.sketch(0, 10, 135)
    image.dissolve(sketch, 0.75, 0.25)
  end

  def fx_gotham(image)
    image.combine_options do |c|
      c.modulate '120,10,100'
      c.fill '#222b6d'
      c.colorize 20
      c.gamma 0.5
      c.contrast
    end
  end

  # image.charcoal if effects =~ /cha/
  # image.duotone                   if effects =~ /duo/
  # image.edge                      if effects =~ /edg/
  # image.emboss                    if effects =~ /emb/
  # image.level_colors              if effects =~ /lev/
  # image.median_filter '0.5'       if effects =~ /med/
  # image.oil_paint                 if effects =~ /oil/
  # image.ordered_dither            if effects =~ /ord|dit|dot|pix/
  # image.posterize                 if effects =~ /pos/
  # image.quantize(256, Magick::GRAYColorspace) if effects =~ /gra|mon/
  # Rand:
  #  geom = Magick::Geometry.new(Magick::QuantumRange / 2)
  #  image.random_threshold_channel(geom, Magick::RedChannel)
  # Sketch:
  #  sketch = image.quantize(256, Magick::GRAYColorspace)
  #  sketch = sketch.equalize
  #  sketch = sketch.sketch(0, 10, 135)
  #  image.dissolve(sketch, 0.75, 0.25)
  # image.spread if effects =~ /spr/
  # image.solarize  if effects =~ /sol/
  # image.threshold(MiniMagick::QuantumRange * 0.55) if effects =~ /thr/


  def post_fx(image, effects, image_record)
    # Any effect that frames the image goes here

    if effects =~ /pol/
      # 'Polaroid' effect
      image[:Caption] = "\n#{ image_record.caption }\n"

      begin
        picture = image.polaroid do
          self.font_weight = MiniMagick::NormalWeight
          self.font_style = MiniMagick::NormalStyle
          self.gravity = MiniMagick::CenterGravity
          self.border_color = '#f0f0f8'
        end

        background = MiniMagick::Image.new(picture.columns, picture.rows)
        image = background.composite(picture, MiniMagick::CenterGravity, MiniMagick::OverCompositeOp)

        rescue NotImplementedError
          return blank_file_name_out
      end
    end

    image.vignette(0.025 * image.columns, 0.025 * image.rows) if effects =~ /vig/

    image
  end
end
