if Rails::VERSION::MAJOR == 5
  %w(
    .ruby-version
    .rbenv-vars
    tmp/restart.txt
    tmp/caching-dev.txt
  ).each { |path| Spring.watch(path) }
end
