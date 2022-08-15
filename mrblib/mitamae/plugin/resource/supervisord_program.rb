module ::MItamae
  module Plugin
    module Resource
      class SupervisordProgram < ::MItamae::Resource::Base
        define_attribute :action, default: :supervise
        define_attribute :name, type: String, default_name: true
        define_attribute :command, type: String, required: true
        define_attribute :settings, type: Hash, default: {}

        self.available_actions = [:supervise, :stop, :start, :restart]
      end
    end
  end
end
