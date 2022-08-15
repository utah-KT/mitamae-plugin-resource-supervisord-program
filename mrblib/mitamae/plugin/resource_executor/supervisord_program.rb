module ::MItamae
  module Plugin
    module ResourceExecutor
      class SupervisordProgram < ::MItamae::ResourceExecutor::Base
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
          run_command("supervisorctl reload") if executor.send(:updated?)
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
