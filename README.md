ruby_module_structure_visualization
===================================

**ruby_graph.rb** is a ruby-script, which creates a DAG of the module structure of a given module.
Module structure means all included modules and all submodules (recursively).
This can be useful for getting a quick overview about a module.

The output of the file is a Graphviz file, which contains the description of the DAG.
This file can be build to a pdf by using Graphviz (I recommend dot).
