module ::MItamae
  module Plugin
    module ResourceExecutor
      class SupervisordProgram < ::MItamae::ResourceExecutor::Base
        WaitReloadError = Class.new(StandardError)
        MAX_WAIT_RELOAD = 5
        def apply
          configure_and_reload
          MItamae.logger.info("supervisord_program[#{desired.name}] configured.")
          supervisord_command(:start) if desired.start
          supervisord_command(:stop) if desired.stop
          supervisord_command(:restart) if desired.restart
        end

        private
        def set_desired_attributes(desired, action)
          desired.supervise = true
          case action
          when :start
            desired.start = true
          when :stop
            desired.stop = true
          when :restart
            desired.restart = true
          end
        end

        def set_current_attributes(current, action)
          current.supervise = false
          case action
          when :start
            current.start = false
          when :stop
            current.stop = false
          when :restart
            current.restart = false
          end
        end

        def configure_and_reload
          @configure ||= with_new_recipe do |recipe|
            MItamae::Resource::Template.new("/etc/supervisor/conf.d/#{desired.name}.conf", recipe, desired: desired) do
              source File.expand_path("templates/supervisord_program.conf.erb", File.expand_path('..', __FILE__))
              variables(
                name: desired.name,
                command: desired.command,
                settings: desired.settings
              )
            end
          end
          executor = MItamae::ResourceExecutor.create(@configure, @runner)
          executor.execute(:create)
          if executor.send(:updated?)
            run_command("supervisorctl reload")
            retry_cnt = 0
            loop do
              result = run_command("supervisorctl status")
              break if result.exit_status == 0
              Open3.capture3("sleep 1")
              next if retry_cnt < MAX_WAIT_RELOAD
              raise WaitReloadError, "failed to wait supervisorctl reload"
            end
          end
        end

        def supervisord_command(action)
          run_command("supervisorctl #{action} #{desired.name}")
          MItamae.logger.info("supervisord_program[#{desired.name}] #{action} #{desired.name}")
        end

        def with_new_recipe(&block)
          new_recipe = MItamae::Recipe.new(@resource.recipe.path, @resource.recipe)
          block.call(new_recipe).tap do |result|
            new_recipe.children << result
          end
        end
      end
    end
  end
end
