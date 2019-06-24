# encoding: utf-8

module EffectsHelper
  def fx(image, effects)
    cycle_effects('fx', image, effects)
  end

  def pre_fx(image, effects)
    cycle_effects('pre_fx', image, effects)
  end

  def post_fx(image, effects)
    cycle_effects('post_fx', image, effects)
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

  def pre_fx_fli(image) #
    image.transpose
  end

  def pre_fx_lef(image) #
    image.transpose
  end

  def pre_fx_rig(image) #
    image.transverse
  end

  def pre_fx_tri(image)
    image.trim
  end

  def fx_cha(image) #
    image.charcoal 3
  end

  def fx_chathin(image) #
    image.charcoal 2
  end

  def fx_colortone(image, color = '#222b6d', level = 100, _type = 0)
    color_image = image.clone
    color_image.combine_options do |c|
      c.fill color
      c.colorize '63%'
    end

    image = image.composite color_image do |c|
      c.compose 'blend'
      c.define "compose:args=#{level},#{100-level}"
    end
  end

  def fx_duo(image)
    image.duotone
  end

  def fx_enh(image)
    image.duotone
  end

  def fx_red(image)
    image.fill 'red'
    image.colorize '50% 25% 50%'
  end

  def fx_gra(image) #
    image.colorspace('Gray')
    image.brightness_contrast('-20x0')
    image = yield(image) if block_given?
    image
  end

  def fx_3d(image) #
    image.raise 20
  end

  def fx_gre(image)
    image.tint '#0f0'
  end

  def fx_grn(image)
    fx_gre(image)
  end

  def fx_blu(image)
    image.fill 'blue'
    image.colorize '25% 25% 50%'
  end

  def fx_enh(image)
    image.combine_options do |c|
      c.auto_level
      c.auto_gamma
    end
  end

  def fx_equ(image) #
    image.equalize
  end

  def fx_flo(image) #
    image.flop
  end

  def fx_gau(image) #
    image.gaussian_blur '0, 1'
  end

  def fx_exp(image) #
    image.implode '-0.75'
  end

  def fx_imp(image) #
    image.implode '-0.75'
  end

  def fx_mod(image)
    image.modulate '0.85'
  end

  def fx_mot(image) #
    image.motion_blur '0, 7, 180'
  end

  def fx_neg(image) #
    image.negate
  end

  def fx_nor(image) #
    image.normalize
  end

  def fx_rad(image) #
    image.radial_blur '5'
  end

  def fx_seg(image)
    image.segment(Magick::YUVColorspace, 0.4, 0.4)
  end

  def fx_sep(image)
    image.combine_options do |c|
      c.auto_level
      c.auto_gamma
      c.sepia_tone '80%'
    end
  end

  def fx_sha(image)
    image.shade(true, 50, 50)
  end

  def fx_swi(image) #
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
    cols, rows = image[:dimensions]
     
    image.combine_options do |cmd|
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

  def fx_fuzz(image)
    image.combine_options do |c|
      c.fuzz "30%"
      #c.trim "+repage"
    end
  end

  def fx_sketch(image) # REVIEW
    image.combine_options do |c|
      c.colorspace('Gray')
      c.contrast
      c.sketch '0x20+135'
    end
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

  def fx_sig(image) #
    image.sigmoidal_contrast '10,0%'
  end

  def fx_paint(image) #
    image.paint 2
  end

  def fx_sol(image) #
    image.solarize '20%'
  end

  def fx_mon(image) #
    image.monochrome
  end

  def fx_dot(image)
    image.ordered_dither
  end

  def post_fx_old1(image) #
    image = fx_sep(image)
    image = vignette(image, 'torn-1')
  end

  def vignette(image, vignette)
    cols, rows = image[:dimensions]

    vignette_image = ::MiniMagick::Image.open("#{ Rails.root }/app/assets/images/vignettes/#{ vignette }.png")
    vignette_image.size "#{ cols }x#{ rows }"

    image = image.composite(vignette_image) do |c|
      c.gravity 'center'
    end
  end
end
