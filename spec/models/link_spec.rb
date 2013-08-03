# encoding: utf-8

describe Link do

  let(:link) { Link.new }
  subject { link }
  before { link.url = 'http://example.com' }

  it { should respond_to(:attempts) }
  it { should respond_to(:author) }
  it { should respond_to(:canonical_url) }
  it { should respond_to(:channel) }
  it { should respond_to(:dirty) }
  it { should respond_to(:domain) }
  it { should respond_to(:error) }
  it { should respond_to(:lang) }
  it { should respond_to(:modified) }
  it { should respond_to(:name) }
  it { should respond_to(:paywall) }
  it { should respond_to(:publisher) }
  it { should respond_to(:title) }
  it { should respond_to(:url) }
  it { should respond_to(:url_or_canonical_url) }
  it { should respond_to(:website_name) }

  it { should validate_presence_of(:url) }

  it { should have_and_belong_to_many(:notes) }

  describe '.grab_urls' do
    before { Link.grab_urls('Body text http://en.wikipedia.org/wiki/Valletta and more text.') }
    it 'adds url' do
      Link.where(url: 'http://en.wikipedia.org/wiki/Valletta', dirty: true).exists?.should eq(true)
    end
  end

  def link_is_updated?
    @link.altitude.should       == nil
    @link.attempts.should       == 0
    @link.author.should         == nil
    @link.canonical_url.should  == 'http://en.wikipedia.org/wiki/Valletta'
    @link.channel.should        == 'en.wikipedia.org'
    @link.dirty.should          == false
    @link.error.should          == nil
    @link.lang.should           == 'en'
    @link.latitude.should       == 35.89778
    @link.longitude.should      == 14.5125
    @link.modified.should       == nil
    @link.paywall.should        == nil
    @link.publisher.should      == nil
    @link.title.should          == 'Valletta'
    @link.url.should            == 'http://en.wikipedia.org/wiki/Valletta'
    @link.website_name.should   == 'Wikipedia, the free encyclopedia'
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
      specify { link.name.should == 'Website name' }
    end

    context 'when website does not have a name' do
      before do
        link.website_name = nil
      end
      it 'uses the channel' do
        link.name.should == 'example.com'
      end
    end
  end

  describe '#headline' do
    before do
      link.website_name = 'Link Name'
    end
    it 'shows correct domain' do
      link.headline.should == 'Link Name'
    end

    context 'when website name is nil' do
      before do
        link.website_name = nil
      end
      it 'returns domain' do
        link.headline.should == link.domain
      end
    end
  end

  describe '#domain' do
    before do
      link.url = 'http://example.com'
    end
    it 'shows correct domain' do
      link.domain.should == 'example.com'
    end

    context 'when url has many parameters' do
      before do
        link.url = 'http://example.com/section/file.php?r=%3243243&b=ddsada'
      end
      specify { link.domain.should eq('example.com') }
    end

    context 'when url includes a subdomain' do
      before do
        link.url = 'http://subdomain.example.com'
      end
      specify { link.domain.should == 'subdomain.example.com' }
    end
  end

  describe '#url_or_canonical_url' do
    context 'when canonical url is present' do
      before do
        link.url = 'http://example.com'
        link.canonical_url = 'http://canonical.example.com'
      end
      it 'returns the canonical url' do
        link.url_or_canonical_url.should == 'http://canonical.example.com'
      end
    end

    context 'when canonical url is not present' do
      before do
        link.url = 'http://example.com'
        link.canonical_url = nil
      end
      it 'returns the url' do
        link.url_or_canonical_url.should == 'http://example.com'
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
    specify { link.protocol.should eq('http') }

    context 'when url has a secure protocol' do
      before do
        link.url = 'https://example.com'
      end
      specify { link.protocol.should eq('https') }
    end
  end
end
