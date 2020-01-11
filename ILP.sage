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

	for v in G.vertices():
		constraint = 0
		for pair in Subsets(G.edges_incident(v),2):
			p.add_constraint(w[pair]<=1)
			constraint = constraint + w[pair]
		p.add_constraint(constraint<=2)
		p.add_constraint(constraint>=2)	
	
	#print p
	p.solve()
	solution = p.get_values(w).items()
	listSetted = []
	for setted in solution:
		if setted[1] == 1.0:
			listSetted.append(setted[0][0])
			listSetted.append(setted[0][1])
			#aux = [setted[0][0]
			#listSetted.append(setted[0])
			#print setted
	disjoitSet = DisjointSet(listSetted)
	print disjoitSet.find((0, 1, None))
    
	