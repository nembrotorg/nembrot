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
      
      if effects =~ /lef/
        image = image.transpose
      end
      image
    end      

    def transverse(image, effects)
      # Rotate right

      if effects =~ /rig/
        image = image.transverse
      end
      image
    end

    def trim(image, effects)
      if effects =~ /tri/
        image = image.trim
      end
      image
    end

    def fx(image, effects)
      if effects =~ /blu/
        image = image.colorize(0.25, 0.25, 0.50, 'blue')
      end

      if effects =~ /cha/
        image = image.charcoal
      end

      if effects =~ /duo/
        image = image.duotone
      end

      if effects =~ /edg/
        image = image.edge
      end

      if effects =~ /emb/
        image = image.emboss
      end

      if effects =~ /enh/
        image = image.enhance
      end

      if effects =~ /equ/
        image = image.equalize
      end

      if effects =~ /exp/
        image = image.implode(-0.75)
      end

      if effects =~ /fli/
        image = image.flip
      end

      if effects =~ /flo/
        image = image.flop
      end

      if effects =~ /gau/
        image = image.gaussian_blur(0, 1)
      end

      if effects =~ /gra|mon/
        image = image.quantize(256, Magick::GRAYColorspace)
      end

      if effects =~ /gre|grn/
        image = image.colorize(0.25, 0.50, 0.25, 'green')
      end

      if effects =~ /imp/
        image = image.implode(0.75)
      end

      if effects =~ /lev/
        image = image.level_colors
      end

      if effects =~ /med/
        image = image.median_filter(0.5)
      end

      if effects =~ /mod/
        image = image.modulate(0.85)
      end

      if effects =~ /mot/
        image = image.motion_blur(0, 7, 180)
      end

      if effects =~ /neg/
        image = image.negate
      end

      if effects =~ /nor|con/
        image = image.normalize
      end

      if effects =~ /oil/
        image = image.oil_paint
      end

      if effects =~ /ord|dit|dot|pix/
        image = image.ordered_dither
      end

      if effects =~ /pos/
        image = image.posterize
      end

      if effects =~ /red/
        image = image.colorize(0.50, 0.25, 0.25, 'red')
      end

      if effects =~ /rad/
        image = image.radial_blur(5)
      end

      if effects =~ /ran|rnd/
        geom = Magick::Geometry.new(Magick::QuantumRange / 2)
        image = image.random_threshold_channel(geom, Magick::RedChannel)
      end

      if effects =~ /seg/
        image = image.segment(Magick::YUVColorspace, 0.4, 0.4)
      end

      if effects =~ /sep/
        image = image.sepiatone(Magick::QuantumRange * 0.8)
      end

      if effects =~ /sha/
        image = image.shade(true, 50, 50)
      end

      if effects =~ /ske/
        sketch = image.quantize(256, Magick::GRAYColorspace)
        sketch = sketch.equalize
        sketch = sketch.sketch(0, 10, 135)
        image = image.dissolve(sketch, 0.75, 0.25)
      end

      if effects =~ /spr/
        image = image.spread
      end

      if effects =~ /sol/
        image = image.solarize
      end

      if effects =~ /swi/
        image = image.swirl(180)
      end

      if effects =~ /thr/
        image = image.threshold(Magick::QuantumRange * 0.55)
      end

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
            self.border_color = "#f0f0f8"
          end

          background = Magick::Image.new(picture.columns, picture.rows)
          image = background.composite(picture, Magick::CenterGravity, Magick::OverCompositeOp)

          rescue NotImplementedError
            return blank_file_name_out
        end
      end

      if effects =~ /vig/
        image = image.vignette(0.025 * image.columns, 0.025 * image.rows)
      end

      image
    end
end
