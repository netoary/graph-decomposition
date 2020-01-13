import time

load('functions.sage')
def solve_direct_ILP(G):
	inicio = time.time()
	p = MixedIntegerLinearProgram(maximization=True,solver="GLPK")
	count = 0
	w = p.new_variable(binary=True)
	constraint = 0
	dic={}
	for e in G.edges():
		dic[e]=[]
	for x in Subsets(G.edges(),5):
		H = Graph()
		H.add_edges(x)
		if isPath(H):
			constraint=constraint+w[x]
			for e in x:
				dic[e].append(x)
			count+=1
	m = G.order()/2
	p.add_constraint(constraint<=m)
	p.add_constraint(constraint>=m)			
	for y in dic:
		constraint=0
		for x in dic[y]:
			constraint=constraint+w[x]
		p.add_constraint(constraint<=1)
	print p
	p.solve()
	sol=p.get_values(w).items()
	setted=[]
	for x in sol:
		if x[1]==1.0:
			setted.append(x[0])
	cor=0
	for x in setted:
		for e in x:
			G.set_edge_label(e[0],e[1],cor)
		cor+=1
	fim = time.time()
	print('tempo de execução' + str(fim-inicio))
	
def solve_direct_ILP_strong(G):
	solved=False
	inicio = time.time()
	p=MixedIntegerLinearProgram(maximization=True,solver="GLPK")
	w=p.new_variable(binary=True)
	objective=0
	dic={}
	for e in G.edges():
		dic[e]=[]
	count=0
	for x in Subsets(G.edges(),5):
		H=Graph()
		H.add_edges(x)
		solve=False
		if isPath(H):
			count+=1
			solve=True
			objective=objective+w[x]
			for e in x:
				dic[e].append(x)
			if count%1000==0:
				print count
				for e in dic:
					constraint=0
					for y in dic[e]:
						constraint=constraint+w[y]
					if dic[e]!=[]:
						p.add_constraint(constraint<=1)
		if count%1000==0 and solve==True:
			p.set_objective(objective)
			p.solve()
			print 'resolveu'
			if p.get_objective_value()==G.order()/2:
				solved=True
				break
		
	if solved==False:
		p.set_objective(objective)
		p.solve()
	sol=p.get_values(w).items()
	setted=[]
	for x in sol:
		if x[1]==1.0:
			setted.append(x[0])
	cor=0
	for x in setted:
		for e in x:
			G.set_edge_label(e[0],e[1],cor)
		cor+=1
	fim = time.time()
	print('tempo de execução' + str(fim-inicio))

def solve_angles_ILP(G):
	inicio = time.time()
	p = MixedIntegerLinearProgram(maximization=True,solver="GLPK")
	count = 0
	w = p.new_variable(binary=True)
	constraint = 0
	dic={}

	vertices = G.vertices()
	for v in vertices:
		constraint = 0
		iterator = Subsets(G.edges_incident(v),2)
		for pair in iterator:
			angle = pair_to_angle([pair[0], pair[1]])
			p.add_constraint(w[angle]<=1)
			constraint = constraint + w[angle]
		p.add_constraint(constraint<=2)
		p.add_constraint(constraint>=2)

	edges = G.edges()
	for e in edges:
		for cont in range(2):
			constraint = 0
			incident = G.edges_incident(e[cont])
			for i in incident:
				if (e != i):
					angle = pair_to_angle([e, i])
					constraint = constraint + w[angle]
			p.add_constraint(constraint<=1)
	
	#print p
	p.solve()
	solution = p.get_values(w).items()
	disjointSet = solution_interpreter(solution)

	cont=0
#	H = Graph()
	for i in disjointSet:
		for e in i:
#			H.add_edge(e[0],e[1],cont)
			G.set_edge_label(e[0],e[1],cont)
		cont += 1
	if disjointSet.number_of_subsets() > G.order()/2:
		isP5Dec=False
	else:
		isP5Dec=isPathDecomposition(G)
	
	cont2=0
	while isP5Dec==False:
		cont2+=1
		print cont2
		for edges in disjointSet:
	#aqui resolvi fixar 5, mas podemos modificar no futuro
			finalConstraints=final_constraints(edges,5,w)
			for constraint in finalConstraints:
				p.add_constraint(constraint[0] <= constraint[1])
		cont=0
	#	H = Graph()
		for i in disjointSet:
			for e in i:
	#			H.add_edge(e[0],e[1],cont)
				G.set_edge_label(e[0],e[1],cont)
			cont += 1
		if disjointSet.number_of_subsets() > G.order()/2:
			isP5Dec=False
		else:
			isP5Dec=isPathDecomposition(G)
def solution_interpreter(solution):
	listSetted = []
	disjointSet = DisjointSet(G.edges())
	for setted in solution:
		if setted[1] == 1.0:
			disjointSet.union(setted[0][0],setted[0][1])

	print disjointSet.number_of_subsets()
	return disjointSet

# Consideramos que pair é um array
def pair_to_angle(pair):
	pair.sort()
	return (pair[0], pair[1])
	
def pair_to_edge(pair):
	pair.sort()
	return (pair[0],pair[1],None)

"""
G = graphs.RandomRegular(5, 8)
dSet = solve_angles_ILP(G)
cont = 0
H = Graph()
for i in dSet:
	for e in i:
		H.add_edge(e[0],e[1],cont)
	cont += 1
		
H.show(color_by_label=true, layout="circular")
"""

def path_constraint(vertices,w):
	constraint=0
	l=len(vertices)
	for i in range(0,l-2):
		edge1 = pair_to_edge([vertices[i],vertices[i+1]])
		edge2 = pair_to_edge([vertices[i+1],vertices[i+2]])
		angle=pair_to_angle([edge1,edge2])
		constraint=constraint+w[angle]
	return constraint

def cycle_constraint(vertices,w):
	constraint=0
	l=len(vertices)
	for i in range(0,l-2):
		edge1 = pair_to_edge([vertices[i],vertices[i+1]])
		edge2 = pair_to_edge([vertices[i+1],vertices[i+2]])
		angle=pair_to_angle([edge1,edge2])
		constraint=constraint+w[angle]
	#ângulos "artificiais"
	edge1 = pair_to_edge([vertices[l-2],vertices[l-1]])
	edge2 = pair_to_edge([vertices[l-1],vertices[0]])
	angle=pair_to_angle([edge1,edge2])
	constraint=constraint+w[angle]
	edge1 = pair_to_edge([vertices[l-1],vertices[0]])
	edge2 = pair_to_edge([vertices[0],vertices[1]])
	angle=pair_to_angle([edge1,edge2])
	constraint=constraint+w[angle]
	return constraint

# suponha que H seja um caminho de order 6, i.e., com 6 vértices
#def path_constraint(H,w):
#	constraint=0
#	for v in H.vertices():
#		if H.degree(v) == 2:
#			angle=pair_to_angle(H.edges_incident(v))
#			constraint=constraint+w[angle]
#	return constraint

#suponha que H é um caminho qualquer, k é o comprimento/número de arestas que quero particionar H
def paths_of_length(H,k):
	result=[]
	o=H.order()
	if o < k+1:
		return result
	ends=[]

	for v in H.vertices():
		if H.degree(v) == 1:
			ends.append(v)
	vertex_list=H.shortest_path(ends[0],ends[1])
	return subpaths(vertice_list,k)
	
def subpaths(vertice_list,k):
	o= len(vertice_list)
	result=[]
	if o<=k:
		return result
	for i in range(o-k):
		path=[]
		for j in range(i,i+k+1):
			path.append(vertex_list[j])
		result.append(path)
	return result		

# k denota o comprimento no qual queremos decompor o grafo, i.e., queremos encontrar uma decomposição em caminhos de comprimento k
def final_constraints(edges,k,w):
	H=Graph(edges)
	constraints=[]
	if isPath(H):
# a próxima função quebra H em caminhos de comprimento k+1
		subpaths=paths_of_length(H,k+1)
		for path in subpaths:
			print "found path"
			constraints.append((path_constraint(path,w),k-1))
		return constraints
		
	basis=H.cycle_basis()
	for cycle in basis:
		if len(cycle) <= k+1:
			print "found small cycle" + str(cycle)
			constraints.append((cycle_constraint(cycle,w),len(cycle)-2))
		else:
			subpaths=subpaths(cycle,k+1)
			for path in subpaths:
				print "found long cycle"
				constraints.append((path_constraint(path,w),k-1))
	return constraints
	

