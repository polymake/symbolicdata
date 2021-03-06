# data extraction from polymake DB in RDF format
# based on a previous script by Andreas Nareike (github.com/nareike)
# (c) 2014 Andreas Paffenholz
# polymake.org

use application "polytope";

my $cone_dim = new Int($ARGV[0]);

my $NS = "http://polymake.org/data/LatticePolytopes/SmoothReflexive/";
my $NSP = "pm";

my @intprops = ("n_vertices", "n_facets", "cone_ambient_dim", "cone_dim", "facet_width", "lattice_volume", "lattice_degree", "lattice_codegree", "n_interior_lattice_points", "n_lattice_points", "n_boundary_lattice_points");
my @booleanprops = ("smooth", "reflexive", "very_ample", "gorenstein");
my @lowercasestringprops = ("date", "contributor");
my @vectorprops = ("h_star_vector","ehrhart_polynomial_coeff","f_vector","facet_widths");

print getPreamble();

my $c = new DatabaseCursor(DATABASE=>"LatticePolytopes",COLLECTION=>"SmoothReflexive", QUERY=>{"CONE_DIM"=>$cone_dim});

while($c->has_next) {
    my $p = $c->next;

    my $polyname = $p->_id;

    my @properties = ();

	foreach (@intprops) {
		my $prop = $_;
		$prop=~s/(\w)/\U$1/g;
		my $val = $p->give($prop);
		push @properties, " $NSP:$_ \"$val\"^^xsd:integer";
	}

	foreach (@booleanprops) {
		my $prop = $_;
		$prop=~s/(\w)/\U$1/g;
		my $val = $p->give($prop);
		push @properties, " $NSP:$_ \"$val\"";
	}

	foreach (@lowercasestringprops) {
		my $prop = $_;
		my $val = $p->give($prop);
		push @properties, " $NSP:$_ \"$val\"";
	}

	foreach (@vectorprops) {
		my $prop = $_;
		$prop=~s/(\w)/\U$1/g;
		my $val = $p->give($prop);
		push @properties, " $NSP:$_ \"$val\"";
	}

	my $dim=$p->give("CONE_DIM")-1;
	my $name = $p->_id;

    my $ttl=<<EOF;
<$NS$name> a pm:SmoothReflexivePolytope ;
 $NSP:hasDimension "$dim" ;
EOF

    $ttl.=join(" ;\n", @properties)." .\n";

    print $ttl . "\n";
}


sub getPreamble {
    return <<'EOF';
@prefix rdf:  <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix owl:  <http://www.w3.org/2002/07/owl#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix xsd:  <http://www.w3.org/2001/XMLSchema#> .

@prefix pm: <http://polymake.org/data/Model#> .


<http://polymake.org/data/LatticePolytopes/SmoothReflexive/>
a owl:Ontology ;
rdfs:comment "Low Dimensional Smooth Reflexive Lattice Polytopes, provided by the polymake project (www.polymake.org), (Benjamin Lorenz, Silke Horn, Andreas Paffenholz)" ;
rdfs:label "SD SmoothReflexivePolytopes" .

pm:SmoothReflexivePolytope
a owl:Class ;
rdfs:label "SmoothReflexivePolytope" .

EOF
}