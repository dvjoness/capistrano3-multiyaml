require 'fileutils'
require 'yaml'
require 'stages'

# Variable interpolation mechanism stolen from Ruby Facets 2.9.3 rather than
# requiring the whole library
def String.interpolate(&str)
  eval "%{#{str.call}}", str.binding
end

begin
  yamlfile = YAML.load_file(fetch(:multiyaml_stages, "config/stages.yml"))
rescue Errno::ENOENT
  abort "Multistage deployment configuration file missing. "\
  "Populate config/stages.yaml or set :multiyaml_stages to another location "\
  "to use capistrano/multiyaml for multistage deployment."
rescue Exception => e
  abort "Configuration file load failed with message: #{e.message}."
end

stages = yamlfile.keys
set(:yaml_stages, stages)

# Loop through YAML configuration file and create a task for each stage.
stages.each do |name|
  desc "Set the target stage to `#{name}'."
  Rake::Task.define_task(name) do
    set(:stage, name.to_sym)
    puts "Setting stage to #{name}"

    # Load the corresponding stage's YAML configuration and iterate through,
    # setting roles, variables, and callbacks as specified.
    config = yamlfile[name.to_s]
    abort "Invalid or missing stage configuration for #{name}." if config.nil?

    invoke 'load:defaults'

    load deploy_config_path
    load "capistrano/#{fetch(:scm)}.rb"

    I18n.locale = fetch(:locale, :en)

    config.each do |section, contents|
      case section.to_s
      # Set variables first so they can be used in roles if necessary.
      when "variables"
        contents.each do |key, value|
          value = value.is_a?(String) ? String.interpolate{value.to_s} : value
          puts "Settings #{key.to_sym} to '#{value}'"
          set(key.to_sym, value)
        end

      when "tasks"
        contents.each do |task|
          target = task['target'].to_s
          action = task['action'].to_s

          case task['type']
          when "before_callback"
            before(target, action)
          when "after_callback"
            after(target, action)
          else
            abort "Wrong callback type - #{task['type']}"
          end
        end

      when "roles"
        contents.each do |rolename, hosts|
          hosts.each do |hostname, options|
            hostname = String.interpolate{hostname.to_s}
            puts "Processing host settings for #{hostname} (#{name})"
            if options.is_a?(Hash) then
              role(rolename.to_sym, hostname.to_s, options)
            else
              role(rolename.to_sym, hostname.to_s)
            end
          end
        end

      else
        puts "Multistage YAML configuration section #{section} ignored by capistrano/multiyaml."
      end

      configure_backend
    end
  end
end

