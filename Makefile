show: buildpdf
	evince ModelStructure.pdf

buildpdf: buildgraphviz
	dot -Tpdf graph.dot -o "ModelStructure.pdf"

buildgraphviz:
	ruby ruby_graph.rb
