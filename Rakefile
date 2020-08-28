require "shellwords"
INSTALL_DIR = "#{ENV["HOME"]}/Music/Audio Music Apps/Articulation Settings"

namespace :vsl do
  namespace :synchron do
    task :clean do
      rm_rf "build/vsl/synchron"
    end

    task :generate do
      sh "ruby src/vsl/synchron/generator.rb src/vsl/synchron/*.yml"
    end

    task :install do
      dir = File.join(INSTALL_DIR, "VSL/Synchron")
      mkdir_p dir
      sh "cp build/vsl/synchron/*.plist #{dir.shellescape}"
    end
  end

  task :clean do
    rm_rf "build/vsl"
  end
  task generate: %w(synchron:generate)
  task install: %w(synchron:install)
end


task :clean do
  rm_rf "build/*"
end
task default: %w(vsl:generate)
task install: %w(vsl:install)
