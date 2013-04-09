# ruby rails-graph.rb && circo -Tsvg graph.vz -o "ActiveSupportStructure.svg" && eog ActiveSupportStructure.svg
require "rails"

def expand(constant)
  included_modules = constant.included_modules
  submodules = constant.constants
    .map do
      |const|
      begin
        constant.const_get(const)
      rescue Exception => e
      end
    end
    .select do |mod|
      (mod.class == Module or mod.class == Class) and mod != BasicObject and mod.name.include?("ActiveSupport")
    end

  if (included_modules.empty? and submodules.empty?)
    return {
      name: constant,
      included_modules: [],
      submodules: []
    }
  else
    {
      name: constant,
      included_modules: included_modules.map do |mod| expand(mod) end,
      submodules: submodules.map do |mod|
        expand(mod)
      end
    }
  end
end

structure = expand(ActiveSupport)
def toGraphviz(file, structure)
  structure[:included_modules].each do |mod|
    file.write("  \"#{structure[:name]}\" -> \"#{mod[:name]}\"\n")
    toGraphviz(file, mod)
  end
  structure[:submodules].each do |mod|
    file.write("  \"#{structure[:name]}\" -> \"#{mod[:name]}\"\n")
    toGraphviz(file, mod)
  end
  
end
File.open("graph.vz", "w") do |f|
  f.write("digraph ActiveSupportStructure {\n")
  f.write("  graph [size=\"11.7,8.3\", ranksep=0.5, nodesep=0.1, overlap=false, start=1]\n")
  toGraphviz(f, structure)
  f.write("}\n")
end
