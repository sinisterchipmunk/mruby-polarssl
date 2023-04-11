#!/usr/bin/env ruby
#
# mrbgems test runner
#

if __FILE__ == $0
  repository, dir = 'https://github.com/mruby/mruby.git', 'tmp/mruby'
  build_args = ARGV

  Dir.mkdir 'tmp'  unless File.exist?('tmp')
  unless File.exist?(dir)
    system "git clone #{repository} --branch 2.1.2 #{dir}"
  end

  exit system(%Q[cd #{dir}; MRUBY_CONFIG=#{File.expand_path __FILE__} ruby minirake #{build_args.join(' ')}])
end

MRuby::Build.new do |conf|
  toolchain :gcc
  conf.gembox 'default'

  conf.gem core: 'mruby-io'
  conf.gem core: 'mruby-pack'
  conf.gem core: 'mruby-socket'
  conf.gem :git => 'git@github.com:iij/mruby-mtest.git'

  conf.gem File.expand_path(File.dirname(__FILE__)) do |c|
    c.add_test_dependency 'mruby-mtest'
  end

  conf.enable_test
end
