#!/usr/bin/env ruby
#
# mrbgems test runner
#

if __FILE__ == $0
  repository, dir = 'https://github.com/mruby/mruby.git', 'tmp/mruby'
  build_args = ARGV

  Dir.mkdir 'tmp'  unless File.exist?('tmp')
  unless File.exist?(dir)
    system "git clone #{repository} --branch 3.2.0 #{dir}"
  end

  exit system(%Q[cd #{dir}; MRUBY_CONFIG=#{File.expand_path __FILE__} ruby minirake #{build_args.join(' ')}])
end

MRuby::Build.new do |conf|
  toolchain :clang
  enable_sanitizer "address,undefined"
  enable_debug
  enable_test # IMPORTANT!
  disable_lock
  conf.cc.flags.delete '-fstack-protector-strong'
  conf.cc.flags += %w( -fpic -fstack-protector-all )

  conf.gembox 'default'

  conf.gem core: 'mruby-io'
  conf.gem core: 'mruby-pack'
  conf.gem core: 'mruby-socket'
  conf.gem mgem: 'mruby-mtest'

  conf.gem File.expand_path(File.dirname(__FILE__)) do |c|
    c.add_test_dependency 'mruby-mtest'
  end
end
