class << $LOAD_PATH
  def merge!(other)
    replace(self | other)
  end
end

$LOAD_PATH.merge! [File.expand_path('../lib', __FILE__)]

Gem::Specification.new do |spec|
  raise 'RubyGems 2.0 or newer is required.' unless spec.respond_to?(:metadata)
  spec.name = 'unversioned_gem_flowdock'
  spec.version = '1.0.1'
  spec.authors = ['Andrew Smith']
  spec.email = ['andrew.smith at moneysupermarket.com']

  spec.summary = 'Notify Flowdock channel on unversioned gem install'
  spec.description = 'Flowdock notifications for CD pipeline if gem installs '\
                     'are encountered that lack a form of version specification'
  spec.homepage = 'https://github.com/MSMFG/rubygem_unversioned_gem_flowdock'
  spec.license = 'Apache-2.0'
  spec.files = `git ls-files -z`.split("\x0")
  spec.add_runtime_dependency 'gem_pre_unversioned_install', '~> 1'
end
