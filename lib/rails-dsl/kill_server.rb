module Rails
  module DSL

    module Commands
      module Helpers
        class << self

          def kill(opid_path)

            opid= File.read(opid_path)
            Process.kill 'HUP', opid.to_i

            $stdout.puts "At pid: #{opid} the app is killed with pidfile: #{opid_path}"
            true
          rescue Errno::ENOENT
            $stdout.puts "#{opid_path} did not exist: Errno::ENOENT"
            true
          rescue Errno::ESRCH
            $stdout.puts "The process #{opid} did not exist: Errno::ESRCH"                
            true
          rescue Errno::EPERM
            $stderr.puts "Lack of privileges to manage the process #{opid}: Errno::EPERM" 
            false
          rescue ::Exception => e
            $stderr.puts "While signaling the PID, unexpected #{e.class}: #{e}"           
            false
          end
          alias kill! kill

        end
      end

      module EXT

        def kill?

          unless %W[ -k --kill ].select{|sym| ARGV.include?(sym) }.empty?

            previous_stderr, $stderr = $stderr, StringIO.new
            previous_stdout, $stdout = $stdout, StringIO.new

            ::Kernel.at_exit do

              $stderr= previous_stderr
              $stdout= previous_stdout

              Rails::Server.new.tap { |server|
                # We need to require application after the server sets environment,
                # otherwise the --environment option given to the server won't propagate.
                require APP_PATH
                Dir.chdir(Rails.application.root)
                Commands::Helpers.kill(server.options[:pid])

              }

              # Rails::Server

            end


          end

        end

      end
    end

    extend Commands::EXT

  end
end

Rails::DSL.kill?