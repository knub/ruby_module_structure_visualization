# For svg:
# ruby <this-file> && dot -Tsvg graph.vz -o "Structure.svg" && eog Structure.svg
# For pdf:
# ruby <this-file> && dot -Tpdf graph.vz -o "Structure.pdf" && evince Structure.pdf

require "rails"

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
    file.write("  \"#{structure[:name]}\" [color=\"#DD6002\"]\n")
  else
    file.write("  \"#{structure[:name]}\" [color=\"#AF0333\"]\n")
  end
  structure[:included_modules].each do |mod|
    file.write("  \"#{structure[:name]}\" -> \"#{mod[:name]}\" [color=\"#8C5E00\"]\n")
  end
  structure[:submodules].each do |mod|
    file.write("  \"#{structure[:name]}\" -> \"#{mod[:name]}\" [color=\"#F7A500\"]\n")
  end
  structure[:included_modules].each do |mod|
    toGraphviz(file, mod)
  end
  structure[:submodules].each do |mod|
    toGraphviz(file, mod, Module == mod[:name].class)
  end
end

File.open("graph.dot", "w") do |f|
  f.write("digraph Structure {\n")
  f.write("  graph [splines=ortho, rankdir=\"LR\", size=\"11.7,8.3!\", overlap=false]\n")
  f.write("  graph [ratio=\"0.7094\", overlap=false]\n")
  f.write("  node [penwidth=6, pad=\"4.0\", shape=polygon, fontsize=30]\n")
  f.write("  node [style=filled]")
  f.write("  node [fillcolor=\"#DDDDDD\"]")
  f.write("  edge [penwidth=5, color=\"#F7A500\"]")
  toGraphviz(f, structure)
  f.write("}\n")
end
