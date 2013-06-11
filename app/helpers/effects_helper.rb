# encoding: utf-8

module EffectsHelper

  private

    def pre_fx(image, effects)
      # Any effect that affects the size of the image goes here
      transpose(image, effects)
      transverse(image, effects)
      trim(image, effects)
      image
    end

    def transpose(image, effects)
      # Rotate left
      image = image.transpose if effects =~ /lef/
      image
    end

    def transverse(image, effects)
      # Rotate right
      image = image.transverse if effects =~ /rig/
      image
    end

    def trim(image, effects)
      image = image.trim if effects =~ /tri/
      image
    end

    def fx(image, effects)
      image = image.colorize(0.25, 0.25, 0.50, 'blue') if effects =~ /blu/
      image = image.charcoal if effects =~ /cha/
      image = image.duotone if effects =~ /duo/
      image = image.edge if effects =~ /edg/
      image = image.emboss if effects =~ /emb/
      image = image.enhance if effects =~ /enh/
      image = image.equalize if effects =~ /equ/
      image = image.implode(-0.75) if effects =~ /exp/
      image = image.flip if effects =~ /fli/
      image = image.flop if effects =~ /flo/
      image = image.gaussian_blur(0, 1) if effects =~ /gau/
      image = image.quantize(256, Magick::GRAYColorspace) if effects =~ /gra|mon/
      image = image.colorize(0.25, 0.50, 0.25, 'green') if effects =~ /gre|grn/
      image = image.implode(0.75) if effects =~ /imp/
      image = image.level_colors if effects =~ /lev/
      image = image.median_filter(0.5) if effects =~ /med/
      image = image.modulate(0.85) if effects =~ /mod/
      image = image.motion_blur(0, 7, 180) if effects =~ /mot/
      image = image.negate if effects =~ /neg/
      image = image.normalize if effects =~ /nor|con/
      image = image.oil_paint if effects =~ /oil/
      image = image.ordered_dither if effects =~ /ord|dit|dot|pix/
      image = image.posterize if effects =~ /pos/
      image = image.colorize(0.50, 0.25, 0.25, 'red') if effects =~ /red/
      image = image.radial_blur(5) if effects =~ /rad/

      if effects =~ /ran|rnd/
        geom = Magick::Geometry.new(Magick::QuantumRange / 2)
        image = image.random_threshold_channel(geom, Magick::RedChannel)
      end

      image = image.segment(Magick::YUVColorspace, 0.4, 0.4) if effects =~ /seg/
      image = image.sepiatone(Magick::QuantumRange * 0.8)   if effects =~ /sep/
      image = image.shade(true, 50, 50) if effects =~ /sha/

      if effects =~ /ske/
        sketch = image.quantize(256, Magick::GRAYColorspace)
        sketch = sketch.equalize
        sketch = sketch.sketch(0, 10, 135)
        image = image.dissolve(sketch, 0.75, 0.25)
      end

      image = image.spread if effects =~ /spr/
      image = image.solarize  if effects =~ /sol/
      image = image.swirl(180) if effects =~ /swi/
      image = image.threshold(Magick::QuantumRange * 0.55) if effects =~ /thr/

      image
    end

    def post_fx(image, effects, image_record)
      # Any effect that frames the image goes here

      if effects =~ /pol/
        # 'Polaroid' effect
        image[:Caption] = "\n#{ image_record.caption }\n"

        begin
          picture = image.polaroid do
            self.font_weight = Magick::NormalWeight
            self.font_style = Magick::NormalStyle
            self.gravity = Magick::CenterGravity
            self.border_color = '#f0f0f8'
          end

          background = Magick::Image.new(picture.columns, picture.rows)
          image = background.composite(picture, Magick::CenterGravity, Magick::OverCompositeOp)

          rescue NotImplementedError
            return blank_file_name_out
        end
      end

      image = image.vignette(0.025 * image.columns, 0.025 * image.rows) if effects =~ /vig/

      image
    end
end
