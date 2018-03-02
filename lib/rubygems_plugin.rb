# Flowdock notifier for unversioned RubyGem installs
require 'rubygems'
require 'erb'
require 'gem_pre_unversioned_install'
# We intentionally use our own Flowdock library as we want to get our gem active
# prior to the large number of depdendencies that the flowdock gem pulls in
require_relative 'nodepflowdock'

# Encapsulate our helpers
module GemFlow
  DEFAULT_TEMPLATE = 'default_template.erb'.freeze
  DEFAULT_HOSTNAME = 'hostname'.freeze
  ENV_FLOW         = 'RUBYGEM_UNVERSIONED_FLOW'.freeze
  ENV_TEMPLATE     = 'RUBYGEM_UNVERSIONED_TEMPLATE'.freeze
  ENV_HOSTNAME_CMD = 'RUBYGEM_UNVERSIONED_HOSTNAME_CMD'.freeze

  # Flow token
  def self.flow
    ENV[ENV_FLOW]
  end

  # Determine template file for message
  def self.template
    unless (file = ENV[ENV_TEMPLATE]) && File.exist?(file)
      file = File.expand_path("../#{DEFAULT_TEMPLATE}", __FILE__)
    end
    ERB.new(File.read(file), nil, '-')
  end

  # Smart hostname
  def self.hostname
    unless (cmd = ENV[ENV_HOSTNAME_CMD]) &&
           which(cmd.split(/\s/, 2).first)
      cmd = DEFAULT_HOSTNAME
    end
    `#{cmd}`.chomp
  end

  # Simple environment indicated file exists
  def self.env_file(var)
    return unless (name = ENV[var])
    # Special helper case for command with args
    return unless File.file?(name.split(/\t/, 2).first)
    name
  end

  # Rubocop clean version from
  # https://stackoverflow.com/questions/2108727/which-in-ruby-checking-if-program-exists-in-path-from-ruby
  def self.which(cmd)
    exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
    ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
      exts.each do |ext|
        exe = File.join(path, "#{cmd}#{ext}")
        return exe if File.executable?(exe) && !File.directory?(exe)
      end
    end
    nil
  end

  private_class_method :env_file
end

Gem.pre_unversioned_install do |name, version|
  next unless (flow = GemFlow.flow)
  hostname = GemFlow.hostname
  message = GemFlow.template.result(binding)
  NoDepFlowdock.chat_message(flow, message, 'RubyGems', 'rubygems', 'version')
  true
end
