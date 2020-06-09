# -*- coding: utf-8 -*-
import time

load('functions.sage')
def solve_direct_ILP(G):
	inicio = time.time()
	p = MixedIntegerLinearProgram(maximization=True,solver="GUROBI")
	#p = MixedIntegerLinearProgram(maximization=True,solver=GurobiBackend)
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
	print('tempo de execução ' + str(fim-inicio))
	
def basic_model(G):
	inicio = time.time()
	p = MixedIntegerLinearProgram(maximization=True,solver="GUROBI")
	count = 0
	w = p.new_variable(binary=True)
	dic={}

	vertices = G.vertices()
	for v in vertices:
		constraint = 0
		iterator = Subsets(G.edges_incident(v),2)
		for pair in iterator:
			angle = pair_to_angle([pair[0], pair[1]])
			constraint = constraint + w[angle]
		p.add_constraint(constraint<=floor(G.degree(v)/2))
		p.add_constraint(constraint>=floor(G.degree(v)/2))

	edges = G.edges()
	for e in edges:
		edge_must_be_in_angle=0
		for cont in range(2):
			constraint = 0
			incident = G.edges_incident(e[cont])
			for i in incident:
				if (e != i):
					angle = pair_to_angle([e, i])
					constraint = constraint + w[angle]
					edge_must_be_in_angle=edge_must_be_in_angle+w[angle]
			p.add_constraint(constraint<=1)
		p.add_constraint(edge_must_be_in_angle>=1)
	return p,w			

def solve_angles_ILP(G):
	inicio = time.time()
	p,w = basic_model(G)
	p.solve()
	solution = p.get_values(w).items()
	#aqui setei (2k+1) = 5
	cycles, paths = solution_cycles(solution, 5)
	noCyclesNPaths = False
	if cycles == []  and paths == []:
		noCyclesNPaths = True
	
	cont_numb_of_solves=0
	while noCyclesNPaths==False:
		for c in cycles:
			p.add_constraint(cycle_constraint_extended(c, w) <= len(c)-3)
		for path in paths:
			#aqui setei (2k+1) = 5
			p.add_constraint(path_constraint(path, w) <= 4)
		p.solve()
		print(p)
		cont_numb_of_solves+=1
		if cont_numb_of_solves%100==0:
			print(cont_numb_of_solves)
			print(p)
		solution = p.get_values(w).items()
		cycles, paths = solution_cycles(solution, 5)
		#print str(cycles) + " ? " + str(paths)
		if cycles == [] and paths == []:
			noCyclesNPaths = True
	
	disjointSet = solution_interpreter(solution)
	cont=0
	H = Graph(G)
	for i in disjointSet:
		for e in i:
			H.set_edge_label(e[0],e[1],cont)
		cont += 1

	fim = time.time()
	print('tempo de execução: ' + str(fim-inicio))
	print('Number of solves: ' + str(cont_numb_of_solves))
	return H,cont_numb_of_solves

def solution_interpreter(solution):
	disjointSet = DisjointSet(G.edges())
	for setted in solution:
		if setted[1] == 1.0:
			disjointSet.union(setted[0][0],setted[0][1])
	return disjointSet
	
def solution_cycles(solution, k):
	disjointSet = DisjointSet(G.edges())
	setted_angles=[]
	dic={}
	for e in G.edges():
		dic[e]=[False]
	for setted in solution:
		if setted[1] == 1.0:
			disjointSet.union(setted[0][0],setted[0][1])
			setted_angles.append(setted[0])
			dic[setted[0][0]].append(setted[0])
			dic[setted[0][1]].append(setted[0])
	
	sequences=[]
	for e in dic:
		if len(dic[e]) == 2 and dic[e][0]==False:
			dic[e][0]=True
			angle=dic[e][1]
			common_vertex=angle_to_common_vertex(angle)
			initial_vertex=edge_to_other_vertex(e,common_vertex)
			new_sequence=[initial_vertex,common_vertex]
			e=angle_to_other_edge(angle,e)
			while len(dic[e]) == 3:
				dic[e][0]=True
				new_vertex=edge_to_other_vertex(e,new_sequence[-1])
				new_sequence.append(new_vertex)
				pair=[dic[e][1],dic[e][2]]
				angle=pair_to_other(pair,angle)
				e = angle_to_other_edge(angle,e)
			dic[e][0]=True
			new_vertex=edge_to_other_vertex(e,new_sequence[-1])
			new_sequence.append(new_vertex)
			sequences.append(new_sequence)
			
	for e in dic:
		if  dic[e][0]==False:
			dic[e][0]=True
			angle=dic[e][1]
			common_vertex=angle_to_common_vertex(angle)
			initial_vertex=edge_to_other_vertex(e,common_vertex)
			new_sequence=[initial_vertex,common_vertex]
			e=angle_to_other_edge(angle,e)
			while dic[e][0]==False:
				dic[e][0]=True
				new_vertex=edge_to_other_vertex(e,new_sequence[-1])
				new_sequence.append(new_vertex)
				pair=[dic[e][1],dic[e][2]]
				angle=pair_to_other(pair,angle)
				e = angle_to_other_edge(angle,e)
			sequences.append(new_sequence)
			
	
	count = []
	cycles = []
	paths = []
	position = []
	for v in G.vertices():
		count.append(0)
		position.append(-1)
		
	for sequence in sequences:
		v=sequence[0]
		pos=0
		isPath = True
		for v in sequence:
			if count[v]==0:
				position[v]=pos
			else:
				cycle=[]
				isPath = False
				for u in range(position[v],pos+1):
					cycle.append(sequence[u])
				cycles.append(cycle)
				position[v]=pos
			count[v]+=1
			pos+=1
		if (isPath == True and len(sequence) > (k+1)):
			paths.append(sequence)
		for u in G.vertices():
			count[u]=0
			position[u]=-1

	return cycles, paths
	
# Consideramos que pair é um array
def pair_to_angle(pair):
	pair.sort()
	return (pair[0], pair[1])
	
def pair_to_edge(pair):
	pair.sort()
	return (pair[0],pair[1],None)
	
def angle_to_common_vertex(angle):
	u,v,label=angle[0]
	x,y,label=angle[1]
	if u == x or u == y:
		return u
	else:
		return v
		
def angle_to_other_edge(angle,edge):
	if edge==angle[0]:
		return angle[1]
	else:
		return angle[0]

def edge_to_other_vertex(edge,vertex):
	if vertex==edge[0]:
		return edge[1]
	else:
		return edge[0]
		
def pair_to_other(pair,sample):
	if sample==pair[0]:
		return pair[1]
	else:
		return pair[0]
		
def cycle_to_angles(cycle):
	angles=[]
	for i in range(0,len(cycle)-2):
		u=cycle[i]
		v=cycle[i+1]
		w=cycle[i+2]
		edge1=pair_to_edge([u,v])
		edge2=pair_to_edge([v,w])
		angle=pair_to_angle([edge1,edge2])
		angles.append(angle)
	u=cycle[-2]
	v=cycle[0]
	w=cycle[1]
	edge1=pair_to_edge([u,v])
	edge2=pair_to_edge([v,w])
	angle=pair_to_angle([edge1,edge2])
	angles.append(angle)
	return angles

		
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

	
# a variável cycle contém o primeiro vértice duas vezes (no começo e no final)
def cycle_constraint_extended(cycle,w):
	angles=cycle_to_angles(cycle)
	constraint=0
	for angle in angles:
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
	vertice_list=H.shortest_path(ends[0],ends[1])
	return subpaths(vertice_list,k)
	
def subpaths(vertice_list,k):
	o= len(vertice_list)
	result=[]
	if o<=k:
		return result
	for i in range(o-k):
		path=[]
		for j in range(i,i+k+1):
			path.append(vertice_list[j])
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
			constraints.append((path_constraint(path,w),k-1))
		return constraints
	return constraints
	

