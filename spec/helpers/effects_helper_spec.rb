# encoding: utf-8

describe EffectsHelper do

  # REVIEW: The only thing these tests actually demonstrate is that the function does not throw an error.
  #  A useful confirmation, but have_dimensions seems to accept any values.

  before do
    @image = MiniMagick::Image.open(File.join(Rails.root, 'public', 'resources', 'cut', 'blank.png'))
    @image.resize '160x90'
  end

  describe '#pre_fx' do
    it 'exists' do
      @image.should { have_dimensions(160, 90) }
    end

    it 'transpose' do
      transpose(@image, 'lef').should { have_dimensions(160, 90) }
    end

    it 'transverse' do
      transpose(@image, 'rig').should { have_dimensions(160, 90) }
    end

    it 'trim' do
      transpose(@image, 'tri').should { have_dimensions(160, 90) }
    end

    it 'pre_fx' do
      pre_fx(@image, 'lef|rig').should { have_dimensions(160, 90) }
    end
  end

  describe '#fx' do
    it 'cha' do
      fx(@image, 'cha').should { have_dimensions(160, 90) }
    end

    it 'red' do
      fx(@image, 'red').should { have_dimensions(160, 90) }
    end

    it 'gre' do
      fx(@image, 'gre').should { have_dimensions(160, 90) }
    end

    it 'blu' do
      fx(@image, 'blu').should { have_dimensions(160, 90) }
    end

    it 'duotone' do
      fx(@image, 'duo').should { have_dimensions(160, 90) }
    end

    it 'edge' do
      fx(@image, 'edg').should { have_dimensions(160, 90) }
    end

    it 'emboss' do
      fx(@image, 'emb').should { have_dimensions(160, 90) }
    end

    it 'enhance' do
      fx(@image, 'enh').should { have_dimensions(160, 90) }
    end

    it 'equalize' do
      fx(@image, 'equ').should { have_dimensions(160, 90) }
    end

    it 'flip' do
      fx(@image, 'fli').should { have_dimensions(160, 90) }
    end

    it 'flop' do
      fx(@image, 'flo').should { have_dimensions(160, 90) }
    end

    it 'gaussian_blur' do
      fx(@image, 'gau').should { have_dimensions(160, 90) }
    end

    it 'implode' do
      fx(@image, 'exp').should { have_dimensions(160, 90) }
    end

    it 'implode' do
      fx(@image, 'imp').should { have_dimensions(160, 90) }
    end

    it 'level_colors' do
      fx(@image, 'lev').should { have_dimensions(160, 90) }
    end

    it 'median_filter' do
      fx(@image, 'med').should { have_dimensions(160, 90) }
    end

    it 'modulate' do
      fx(@image, 'mod').should { have_dimensions(160, 90) }
    end

    it 'motion_blur' do
      fx(@image, 'mot').should { have_dimensions(160, 90) }
    end

    it 'negate' do
      fx(@image, 'neg').should { have_dimensions(160, 90) }
    end

    it 'normalize' do
      fx(@image, 'nor|con').should { have_dimensions(160, 90) }
    end

    it 'oil_paint' do
      fx(@image, 'oil').should { have_dimensions(160, 90) }
    end

    it 'ordered_dither' do
      fx(@image, 'ord').should { have_dimensions(160, 90) }
    end

    it 'posterize' do
      fx(@image, 'pos').should { have_dimensions(160, 90) }
    end

    it 'quantize' do
      fx(@image, 'gra').should { have_dimensions(160, 90) }
    end

    it 'radial_blur' do
      fx(@image, 'rad').should { have_dimensions(160, 90) }
    end

    it 'random_threshold_channel' do
      fx(@image, 'rnd').should { have_dimensions(160, 90) }
    end

    it 'spread' do
      fx(@image, 'spr').should { have_dimensions(160, 90) }
    end

    it 'solarize' do
      fx(@image, 'sol').should { have_dimensions(160, 90) }
    end

    it 'swirl' do
      fx(@image, 'swi').should { have_dimensions(160, 90) }
    end

    it 'threshold' do
      fx(@image, 'thr').should { have_dimensions(160, 90) }
    end
  end

  describe '#post_fx' do
    before do
      note = FactoryGirl.create(:note)
      @resource = FactoryGirl.create(:resource, note: note)
    end
    it 'polaroid' do
      pending "post_fx(@image, 'pol', @resource).should { have_dimensions(160, 90) }"
    end
  end
end
