namespace :VSL do
  namespace :Synchron do
    task :generate do
      sh "ruby VSL/Synchron/src/generator.rb VSL/Synchron/src/*.yml"
    end

    task :clean do
      sh "rm -f VSL/Synchron/*.plist"
    end
  end

  task :generate => %w(Synchron:generate)
  task :clean => %w(Synchron:clean)
end

task clean: %w(VSL:clean)
task default: %w(VSL:generate)
