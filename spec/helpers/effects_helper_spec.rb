# encoding: utf-8

RSpec.describe EffectsHelper do
  # REVIEW: The only thing these tests actually demonstrate is that the function does not throw an error.
  #  A useful confirmation, but have_dimensions seems to accept any values.

  before do
    @image = MiniMagick::Image.open(File.join(Rails.root, 'public', 'resources', 'cut', 'blank.png'))
    @image.resize '160x90'
  end

  describe '#pre_fx' do
    it 'exists' do
      expect(@image).to be { have_dimensions(160, 90) }
    end

    it 'transpose' do
      expect(pre_fx(@image, 'lef')).to be { have_dimensions(160, 90) }
    end

    it 'transverse' do
      expect(pre_fx(@image, 'rig')).to be { have_dimensions(160, 90) }
    end

    it 'trim' do
      expect(pre_fx(@image, 'tri')).to be { have_dimensions(160, 90) }
    end

    it 'pre_fx' do
      expect(pre_fx(@image, 'lef|rig')).to be { have_dimensions(160, 90) }
    end
  end

  describe '#fx' do
    it 'cha' do
      expect(fx(@image, 'cha')).to be { have_dimensions(160, 90) }
    end

    it 'red' do
      expect(fx(@image, 'red')).to be { have_dimensions(160, 90) }
    end

    it 'gre' do
      expect(fx(@image, 'gre')).to be { have_dimensions(160, 90) }
    end

    it 'blu' do
      expect(fx(@image, 'blu')).to be { have_dimensions(160, 90) }
    end

    it 'duotone' do
      expect(fx(@image, 'duo')).to be { have_dimensions(160, 90) }
    end

    it 'edge' do
      expect(fx(@image, 'edg')).to be { have_dimensions(160, 90) }
    end

    it 'emboss' do
      expect(fx(@image, 'emb')).to be { have_dimensions(160, 90) }
    end

    it 'enhance' do
      expect(fx(@image, 'enh')).to be { have_dimensions(160, 90) }
    end

    it 'equalize' do
      expect(fx(@image, 'equ')).to be { have_dimensions(160, 90) }
    end

    it 'flip' do
      expect(fx(@image, 'fli')).to be { have_dimensions(160, 90) }
    end

    it 'flop' do
      expect(fx(@image, 'flo')).to be { have_dimensions(160, 90) }
    end

    it 'gaussian_blur' do
      expect(fx(@image, 'gau')).to be { have_dimensions(160, 90) }
    end

    it 'implode' do
      expect(fx(@image, 'exp')).to be { have_dimensions(160, 90) }
    end

    it 'implode' do
      expect(fx(@image, 'imp')).to be { have_dimensions(160, 90) }
    end

    it 'level_colors' do
      expect(fx(@image, 'lev')).to be { have_dimensions(160, 90) }
    end

    it 'median_filter' do
      expect(fx(@image, 'med')).to be { have_dimensions(160, 90) }
    end

    it 'modulate' do
      expect(fx(@image, 'mod')).to be { have_dimensions(160, 90) }
    end

    it 'motion_blur' do
      expect(fx(@image, 'mot')).to be { have_dimensions(160, 90) }
    end

    it 'negate' do
      expect(fx(@image, 'neg')).to be { have_dimensions(160, 90) }
    end

    it 'normalize' do
      expect(fx(@image, 'nor|con')).to be { have_dimensions(160, 90) }
    end

    it 'oil_paint' do
      expect(fx(@image, 'oil')).to be { have_dimensions(160, 90) }
    end

    it 'ordered_dither' do
      expect(fx(@image, 'ord')).to be { have_dimensions(160, 90) }
    end

    it 'posterize' do
      expect(fx(@image, 'pos')).to be { have_dimensions(160, 90) }
    end

    it 'quantize' do
      expect(fx(@image, 'gra')).to be { have_dimensions(160, 90) }
    end

    it 'radial_blur' do
      expect(fx(@image, 'rad')).to be { have_dimensions(160, 90) }
    end

    it 'random_threshold_channel' do
      expect(fx(@image, 'rnd')).to be { have_dimensions(160, 90) }
    end

    it 'spread' do
      expect(fx(@image, 'spr')).to be { have_dimensions(160, 90) }
    end

    it 'solarize' do
      expect(fx(@image, 'sol')).to be { have_dimensions(160, 90) }
    end

    it 'swirl' do
      expect(fx(@image, 'swi')).to be { have_dimensions(160, 90) }
    end

    it 'threshold' do
      expect(fx(@image, 'thr')).to be { have_dimensions(160, 90) }
    end
  end

  describe '#post_fx' do
    before do
      note = FactoryGirl.create(:note)
      @resource = FactoryGirl.create(:resource, note: note)
    end
    it 'polaroid' do
      # pending "post_fx(@image, 'pol', @resource).should { have_dimensions(160, 90) }"
    end
  end
end
