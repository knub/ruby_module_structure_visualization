# ruby rails-graph.rb && circo -Tsvg graph.vz -o "Structure.svg" && eog Structure.svg

# For pdf:
# ruby rails-graph.rb && dot -Tpdf graph.vz -o "ActiveSupportStructure.pdf" && e ActiveSupportStructure.pdf
require "rails"
require "active_record"

CONST = ActiveSupport

def expand(constant)
  included_modules = constant.included_modules.select do |mod|
    mod.name && mod.name.include?(constant.name)
  end
  submodules = constant.constants
    .map do
      |const|
      begin
        constant.const_get(const)
      rescue Exception => e
      end
    end
    .select do |mod|
      (mod.class == Module or mod.class == Class) and mod != BasicObject and mod.name && mod.name.include?(constant.name)
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

structure = expand(CONST)
def toGraphviz(file, structure, isModule = true)
  if isModule
    file.write("  \"#{structure[:name]}\" [color=deeppink]\n")
  else
    file.write("  \"#{structure[:name]}\" [color=green]\n")
  end
  structure[:included_modules].each do |mod|
    file.write("  \"#{structure[:name]}\" -> \"#{mod[:name]}\" [color=\"#FF0000\"]\n")
  end
  structure[:submodules].each do |mod|
    file.write("  \"#{structure[:name]}\" -> \"#{mod[:name]}\" [color=\"#0000FF\"]\n")
  end
  structure[:included_modules].each do |mod|
    toGraphviz(file, mod)
  end
  structure[:submodules].each do |mod|
    toGraphviz(file, mod, Module == mod[:name].class)
  end
  
end
File.open("graph.vz", "w") do |f|
  f.write("digraph ActiveSupportStructure {\n")
  f.write("  graph [rankdir=\"LR\", size=\"11.7,8.3!\", overlap=false]\n")
  f.write("  graph [ratio=\"0.7094\", overlap=false]\n")
  f.write("  node [fontname=Verdana,fontsize=20]\n")
  f.write("  node [style=filled]")
  f.write("  node [fillcolor=\"#EEEEEE\"]")
  f.write("  node [color=\"#EEEEEE\"]")
  f.write("  edge [color=\"#31CEF0\"]")
  toGraphviz(f, structure)
  f.write("}\n")
end
