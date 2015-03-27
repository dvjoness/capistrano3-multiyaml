module Capistrano::DSL::Stages
  def stages
    # Add stages defined in stages.yml to standard stages definitions (config/deploy/*.rb)
    Dir[stage_definitions].map { |f| File.basename(f, '.rb') } + fetch(:yaml_stages, [])
  end
end