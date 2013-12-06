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
      image.transpose if effects =~ /lef/   # Rotate left
    end

    def transverse(image, effects)
      image.transverse if effects =~ /rig/  # Rotate right
    end

    def trim(image, effects)
      image.trim if effects =~ /tri/
    end

    def fx(image, effects)
      # image.charcoal if effects =~ /cha/

      if effects =~ /red/
        image.fill 'red'
        image.colorize '50% 25% 50%'
      end

      if effects =~ /gre|grn/
        image.fill 'green'
        image.colorize '25% 50% 25%'
      end

      if effects =~ /blu/
        image.combine_options do |c|
          c.fill 'blue'
          c.colorize '25% 25% 50%'
        end
      end

      # image.duotone                   if effects =~ /duo/
      # image.edge                      if effects =~ /edg/
      # image.emboss                    if effects =~ /emb/
      image.enhance                   if effects =~ /enh/
      image.equalize                  if effects =~ /equ/
      image.flip                      if effects =~ /fli/
      image.flop                      if effects =~ /flo/
      image.gaussian_blur '0, 1'       if effects =~ /gau/
      image.implode '-0.75'           if effects =~ /exp/
      image.implode '0.75'            if effects =~ /imp/
      # image.level_colors              if effects =~ /lev/
      # image.median_filter '0.5'       if effects =~ /med/
      image.modulate '0.85'           if effects =~ /mod/
      image.motion_blur '0, 7, 180'   if effects =~ /mot/
      image.negate                    if effects =~ /neg/
      image.normalize                 if effects =~ /nor|con/
      # image.oil_paint                 if effects =~ /oil/
      # image.ordered_dither            if effects =~ /ord|dit|dot|pix/
      # image.posterize                 if effects =~ /pos/
      # image.quantize(256, Magick::GRAYColorspace) if effects =~ /gra|mon/
      image.radial_blur '5'           if effects =~ /rad/

      if effects =~ /ran|rnd/
        # geom = Magick::Geometry.new(Magick::QuantumRange / 2)
        # image.random_threshold_channel(geom, Magick::RedChannel)
      end

      image.segment(Magick::YUVColorspace, 0.4, 0.4) if effects =~ /seg/
      image.sepiatone 'Magick::QuantumRange * 0.8'   if effects =~ /sep/
      image.shade(true, 50, 50) if effects =~ /sha/

      if effects =~ /ske/
        # sketch = image.quantize(256, Magick::GRAYColorspace)
        # sketch = sketch.equalize
        # sketch = sketch.sketch(0, 10, 135)
        # image.dissolve(sketch, 0.75, 0.25)
      end

      # image.spread if effects =~ /spr/
      # image.solarize  if effects =~ /sol/
      image.swirl '180' if effects =~ /swi/
      # image.threshold(MiniMagick::QuantumRange * 0.55) if effects =~ /thr/

      image
    end

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
