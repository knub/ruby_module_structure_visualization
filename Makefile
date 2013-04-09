show: buildpdf
	evince ModelStructure.pdf

buildpdf: buildgraphviz
	dot -Tpdf graph.vz -o "ModelStructure.pdf"

buildgraphviz:
	ruby ruby_graph.rb
