show: buildpdf
	evince ModelStructure.pdf

buildpdf: buildgraphviz
	dot -Tpdf graph.vz -o "ModelStructure.pdf"

buildgraphviz:
	ruby rails-graph.rb
