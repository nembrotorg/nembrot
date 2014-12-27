# encoding: utf-8

describe Link do

  let(:link) { Link.new }
  subject { link }
  before { link.url = 'http://example.com' }

  it { is_expected.to respond_to(:attempts) }
  it { is_expected.to respond_to(:author) }
  it { is_expected.to respond_to(:canonical_url) }
  it { is_expected.to respond_to(:channel) }
  it { is_expected.to respond_to(:dirty) }
  it { is_expected.to respond_to(:domain) }
  it { is_expected.to respond_to(:error) }
  it { is_expected.to respond_to(:lang) }
  it { is_expected.to respond_to(:modified) }
  it { is_expected.to respond_to(:name) }
  it { is_expected.to respond_to(:paywall) }
  it { is_expected.to respond_to(:publisher) }
  it { is_expected.to respond_to(:title) }
  it { is_expected.to respond_to(:url) }
  it { is_expected.to respond_to(:url_or_canonical_url) }
  it { is_expected.to respond_to(:website_name) }

  it { is_expected.to validate_presence_of(:url) }

  it { is_expected.to have_and_belong_to_many(:notes) }

  describe '.grab_urls' do
    before { Link.grab_urls('Body text http://en.wikipedia.org/wiki/Valletta and more text.') }
    it 'adds url' do
      expect(Link.where(url: 'http://en.wikipedia.org/wiki/Valletta', dirty: true).exists?).to be_truthy
    end

    context 'when url is local' do
      before { Link.grab_urls("Body text http://#{ Constant.host }/path and more text.") }
      it 'does not add url' do
        expect(Link.where(url: "http://#{ Constant.host }/path").exists?).to be_falsey
      end
    end

    context 'when url is on a subdomain of local' do
      before { Link.grab_urls("Body text http://#{ Constant.host }/path and more text.") }
      it 'does not add url' do
        expect(Link.where(url: "http://v1.#{ Constant.host }/path").exists?).to be_falsey
      end
    end
  end

  def link_is_updated?
    expect(@link.altitude).to       eq(nil)
    expect(@link.attempts).to       eq(0)
    expect(@link.author).to         eq(nil)
    expect(@link.canonical_url).to  eq('http://en.wikipedia.org/wiki/Valletta')
    expect(@link.channel).to        eq('en.wikipedia.org')
    expect(@link.dirty).to          eq(false)
    expect(@link.error).to          eq(nil)
    expect(@link.lang).to           eq('en')
    expect(@link.latitude).to       eq(35.89778)
    expect(@link.longitude).to      eq(14.5125)
    expect(@link.modified).to       eq(nil)
    expect(@link.paywall).to        eq(nil)
    expect(@link.publisher).to      eq(nil)
    expect(@link.title).to          eq('Valletta')
    expect(@link.url).to            eq('http://en.wikipedia.org/wiki/Valletta')
    expect(@link.website_name).to   eq('Wikipedia, the free encyclopedia')
  end

  describe '#populate!' do
    before do
      @link = Link.add_task('http://en.wikipedia.org/wiki/Valletta')
      @link.populate!
    end
    it 'fetches metadata from the site' do
      link_is_updated?
    end
  end

  describe '#name' do
    context 'when website has a name' do
      before do
        link.website_name = 'Website name'
      end
      specify { expect(link.name).to eq('Website name') }
    end

    context 'when website does not have a name' do
      before do
        link.website_name = nil
      end
      it 'uses the channel' do
        expect(link.name).to eq('example.com')
      end
    end
  end

  describe '#headline' do
    before do
      link.website_name = 'Link Name'
    end
    it 'shows correct domain' do
      expect(link.headline).to eq('Link Name')
    end

    context 'when website name is nil' do
      before do
        link.website_name = nil
      end
      it 'returns domain' do
        expect(link.headline).to eq(link.domain)
      end
    end
  end

  describe '#domain' do
    before do
      link.url = 'http://example.com'
    end
    it 'shows correct domain' do
      expect(link.domain).to eq('example.com')
    end

    context 'when url has many parameters' do
      before do
        link.url = 'http://example.com/section/file.php?r=%3243243&b=ddsada'
      end
      specify { expect(link.domain).to eq('example.com') }
    end

    context 'when url includes a subdomain' do
      before do
        link.url = 'http://subdomain.example.com'
      end
      specify { expect(link.domain).to eq('subdomain.example.com') }
    end
  end

  describe '#url_or_canonical_url' do
    context 'when canonical url is present' do
      before do
        link.url = 'http://example.com'
        link.canonical_url = 'http://canonical.example.com'
      end
      it 'returns the canonical url' do
        expect(link.url_or_canonical_url).to eq('http://canonical.example.com')
      end
    end

    context 'when canonical url is not present' do
      before do
        link.url = 'http://example.com'
        link.canonical_url = nil
      end
      it 'returns the url' do
        expect(link.url_or_canonical_url).to eq('http://example.com')
      end
    end
  end

  describe '#channel' do
    before do
      link.url = 'http://example.com'
      link.valid?
    end
    its(:channel) { should == 'example.com' }
  end

  describe '#protocol' do
    before do
      link.url = 'http://example.com'
    end
    specify { expect(link.protocol).to eq('http') }

    context 'when url has a secure protocol' do
      before do
        link.url = 'https://example.com'
      end
      specify { expect(link.protocol).to eq('https') }
    end
  end
end
