RSpec.describe Rack::DomainFilter do

  def app
    builder = Rack::Builder.new
    builder.use Rack::DomainFilter, config: config
    builder.run outer_app

    builder
  end

  let(:config) { Rack::DomainFilter::Configuration.new }
  let(:outer_app) { ->(env) { [200, {'Content-Type' => 'text/plain'}, ['All responses are OK']] } }

  describe '#catch_exception' do
    class RackError < StandardError
    end

    class ChildError < RackError
    end

    class OtherError < StandardError
    end

    before do
      config.filter_for 'childerror.dev' do |slug|
        raise ChildError, 'child_error'
      end

      config.filter_for 'raiseothererror.dev' do |slug|
        raise OtherError, 'other_error'
      end

      config.catch RackError do
        [404, {'Content-Type' => 'text/plain'}, ["rack error!"]]
      end

      config.catch OtherError do
        [404, {'Content-Type' => 'text/plain'}, ["other error!"]]
      end
    end

    let(:outer_app) { ->(env) { raise 'internal-error' } }

    it 'works' do
      request '/cihuy', 'HTTP_HOST' => 'childerror.dev'
      expect(last_response.body).to eq('rack error!')

      request '/fractalstory', 'HTTP_HOST' => 'raiseothererror.dev'
      expect(last_response.body).to eq('other error!')

      expect { get '/fractalstory' }.to raise_error('internal-error')
    end
  end

  describe '#match_uri' do
    before do
      config.filter_for(/(.+).local.dev/) do |slug|
        Thread.current[:company] = "#{slug}_test"
      end

      config.filter_for(/(.+).peentar.id/) do |slug|
        Thread.current[:company] = "#{slug}_production"
      end

      config.filter_for(/(.+).peentar.id/) do |slug|
        Thread.current[:company] = "#{slug}_production"
      end

      config.filter_for 'kucingstory.id' do
        Thread.current[:company] = "tenant-kucingstory"
      end

      config.no_match do
        [404, {'Content-Type' => 'text/plain'}, ["nothing found!"]]
      end

      config.after_request do
        Thread.current[:company] = nil
      end
    end

    let(:outer_app) { ->(env) { [200, {'Content-Type' => 'text/plain'}, ["Company is #{Thread.current[:company]}"]] } }

    it 'actually works' do
      expect(Thread.current[:company]).to be_nil

      request '/cihuy', 'HTTP_HOST' => 'kucing-lucu.local.dev'
      expect(last_response.body).to eq('Company is kucing-lucu_test')

      request '/fractalstory', 'HTTP_HOST' => 'kucing.peentar.id'
      expect(last_response.body).to eq('Company is kucing_production')

      request '/fractalstory', 'HTTP_HOST' => 'kucingstory.id'
      expect(last_response.body).to eq('Company is tenant-kucingstory')

      request '/fractalstory', 'HTTP_HOST' => 'elitehacker.org'
      expect(last_response.body).to eq('nothing found!')

      get '/fractalstory'
      expect(last_response.body).to eq('nothing found!')

    end
  end

  describe '#run_after_request' do
    before do
      config.allow_passthrough
      config.after_request { set_current(:cumi, 'goreng') }
    end

    it 'actually works' do
      set_current(:cumi, 'bakar')
      get '/'

      expect(Thread.current[:cumi]).to eq('goreng')
    end
  end

  describe '#skip_for' do
    before do
      config.no_match do
        [404, {'Content-Type' => 'text/plain'}, ["nothing found!"]]
      end

      config.skip_path_for '/fractalstory'
      config.skip_path_for (/wowkeren/)
    end

    it 'actually works' do
      expect(Thread.current[:company]).to be_nil

      request '/fractalstory?cumi=enak', 'HTTP_HOST' => 'kucing.peentar.id'
      expect(last_response.body).to eq('All responses are OK')

      request '/wowkeren', 'HTTP_HOST' => 'kucing.peentar.id'
      expect(last_response.body).to eq('All responses are OK')

      request '/cihuy', 'HTTP_HOST' => 'kucing-lucu.local.dev'
      expect(last_response.body).to eq('nothing found!')

      request '/fractalstory', 'HTTP_HOST' => 'kucing.peentar.id'
      expect(last_response.body).to eq('All responses are OK')
    end
  end

  describe 'Configuration' do
  end
end
