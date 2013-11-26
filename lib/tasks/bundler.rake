namespace "bundler" do
  desc "Install gems"
  task "install" do
    sh("bundle install")
  end

  desc "Install gems for test"
  task "install:test" do
    sh("bundle install --without development production")
  end

  desc "Install gems for production"
  task "install:production" do
    sh("bundle install --without development test")
  end

  desc "Install gems for development"
  task "install:development" do
    sh("bundle install --without test production")
  end
end
