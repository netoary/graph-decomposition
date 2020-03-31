#Falta fazer a decomposição canonica generica
## onde com apenas uma função e parametros ela faz todas as ações das outras


def dictionaryMaker(graph):
	# returns a dictionary containing the edges separated by the label (from 0 to n / 2)
	dic = {}
	edges=graph.edges()
	n = graph.order()
	for i in range(n/2):
		dic[i]=[]
	for i in edges:
		dic[i[2]].append(i)
	return dic

def extractColor(graph,color):
	# returns a list of the edges that have this color.
	result=[]
	for edge in graph.edges():
		if edge[2] == color:
			result.append(edge)
	return result

def isTrail(subgraph):
	# Checks whether a subgraph is an open trail
	# returns True if it is and otherwise False
	if (subgraph.is_connected()):
		aux = 0
		for i in subgraph.degree():
			if (mod(i,2)==1):
				aux +=1
		if (aux == 2):
			return True
		else:
			return False
	return False

def isTrailDecomposition(graph):
	# tests whether the decomposition is decomposing into paths
	# returns True if it is and otherwise False
	dic = {}
	edges=graph.edges()
	n = graph.order()
	for i in range(n/2):
		dic[i]=[]
	for i in edges:
		dic[i[2]].append(i)
	for i in dic:
		H = Graph(dic[i])
		if (isTrail(H) == False):
			return False
	return True

def is_d_Decomposition(graph):
	# test whether a given labeling is a d-decomposition
	# i.e. if the frequency of each edge label is the same
	# returns True if it is and otherwise False
	aux = 0
	n = len(graph)
	l = []
	d = []
	for i in graph.edges():
		l.append(graph.edge_label(i[0], i[1]))
	for i in l:
		d.append(l.count(i))
	cont = 0
	cont = d.count(d[0])
	for i in d:
		if (d.count(i) != cont):
			return False
	return True

def labelInducesTrail(graph):
	# tests whether a given labeling induces a decomposition into trails
	# returns True if all colors induce 
	if(is_d_Decomposition(graph) == False):
		return False
	dic = {}
	edges=graph.edges()
	n = graph.order()
	for i in range(n/2):
		dic[i]=[]
	for i in edges:
		dic[i[2]].append(i)
	for i in dic:
		H = Graph(dic[i])
		if (isTrail(H) == False):
			return False
	return True

def canonicalDecomposition(graph, M = [], petersen = []):
	# If graph does not have perfect matching the function returns "False"
	# petersen is a list of 2-factors without M, which is a graph matching
	# For each edge in a 2-factor its label is changed
	# If for each matching of M a trail is generated (identified by the labels between 0 and (m / r) -1),
	# the function returns "True"
	
	if M == []:
		M = graph.matching(algorithm="Edmonds")
		
	H=copy(G)
	H.delete_edges(M)
	if petersen == []:
		petersen = H.two_factor_petersen()

	labeling = len(graph)
	if (len(M) != labeling/2):
		return False
	'''
	for i in M:
		graph.delete_edge(i)
	for i in range(len(petersen)):
		for j in petersen[i]:
			graph.set_edge_label(j[0], j[1], labeling + i)
	'''
	cont = 0
	for i in M:
		x = i[0]
		y = i[1]
		graph.set_edge_label(x, y, cont)
		for k in range(len(petersen)):
			for j in petersen[k]:
				if (j[0] == x):
					graph.set_edge_label(j[0], j[1], cont)
					x = j[1]
					break
			for j in petersen[k]:
				if (j[0] == y):
					graph.set_edge_label(j[0], j[1], cont)
					y = j[1]
					break
		cont += 1

def allowCanonicalDecomposition(graph, allow_k4minuses = True, allow_triangles = True, allow_squares = True, allow_connection_vertex_whithout_hanging_edge = True):
	# Canonical decomposition where it is possible to select which of the trails are formed
	# return True, if there is at least one decomposition requested
	M = graph.matching(algorithm="Edmonds")
	if (len(M) != len(graph)/2):
		return False
	for M in graph.perfect_matchings():
		stop = True
		for i in M:
			graph.delete_edge(i)
		petersen = graph.two_factor_petersen()
		for i in M:
			graph.add_edge(i[0], i[1], "P")
		dec=canonicalDecomposition(graph,M,petersen)
		a,b,c=badsCounter(graph)
		d = hangConnectionVertexs(graph)
		if (not allow_k4minuses and c>0):
			stop = False
		if (not allow_triangles and a>0):
			stop = False
		if (not allow_squares and b>0):
			stop = False
		if (not allow_connection_vertex_whithout_hanging_edge and d):
			stop = False
		if (stop == True):
			break
	return stop

def nok4minusCanonicalDecomposition(graph):
	M = graph.matching(algorithm="Edmonds")
	if (len(M) != len(graph)/2):
		return False
	for M in graph.perfect_matchings():
		for i in M:
			graph.delete_edge(i)
		petersen = graph.two_factor_petersen()
		for i in M:
			graph.add_edge(i[0], i[1], "P")
		dec=canonicalDecomposition(graph,M,petersen)
		a,b,c=badsCounter(graph)
		if c==0:
			break
	return

def isPath(graph):
	# return True whether an element is a path
	if (isTrail(graph) == False):
		return False
	l = graph.degree()
	if (max(l) == 2):
		return True
	return False

def isPathDecomposition(graph):
	# return True whether the decomposition is decomposing into paths
	dic = {}
	edges=graph.edges()
	n = graph.order()
	for i in range(n/2):
		dic[i]=[]
	for i in edges:
		dic[i[2]].append(i)
	for i in dic:
		H = Graph(dic[i])
		if (isPath(H) == False):
			return False
	return True

def takeHangingEdges(graph):
	# tests whether the decomposition is decomposing into paths
	# returns a dictionary with Hanging Edges in each vertex
	hangingEdges = {}
	dic = {}
	edges=graph.edges()
	n = graph.order()
	cont = 0
	for i in range(n/2):
		dic[i]=[]
	for i in edges:
		dic[i[2]].append(i)
	for i in dic:
		H = Graph(dic[i])
		for j in H.edges():
			if (mod(H.degree(j[0]),2)==1):
				X = Graph(H)
				X.delete_edge(j)
				if (X.is_connected() or H.degree(j[0])==1):
					if (j[1] in hangingEdges):
						hangingEdges[j[1]].append(j)
					else:
						hangingEdges[j[1]] = [j]
					cont += 1

			if (mod(H.degree(j[1]),2)==1):
				X = Graph(H)
				X.delete_edge(j)
				if (X.is_connected() or H.degree(j[1])==1):
					if (j[0] in hangingEdges):
						hangingEdges[j[0]].append(j)
					else:
						hangingEdges[j[0]] = [j]
					cont += 1
	if (cont == n):
		return True
	return hangingEdges

def possibleMoves(graph,hangingEdges):
	#returns possible moves
	moves = []
	for i in hangingEdges:
		if (len(hangingEdges[i]) >= 2):
			for j in hangingEdges[i]:
				for k in hangingEdges[i]:
					if (j[2] != k[2]):
						trail1=Graph(extractColor(graph,j[2]))
						trail2=Graph(extractColor(graph,k[2]))
						dotheypointtodegree1vertex = (trail1.degree(j[0])==1 or trail1.degree(j[1])==1) and (trail2.degree(k[0]) or trail2.degree(k[1]))
						if (not([j,k] in moves or [k,j] in moves)) and not dotheypointtodegree1vertex:
							moves.append([j,k])
	return moves

def move(graph, pair):
	#change the label of the pair of edges
	e,f=pair
	x1,y1,l1 = e
	x2,y2,l2 = f
	graph.set_edge_label(x1,y1,l2)
	graph.set_edge_label(x2,y2,l1)

def unmove(graph, pair):
	#exchange the label of the pair of edges
	e,f=pair
	x1,y1,l1 = e
	x2,y2,l2 = f
	graph.set_edge_label(x1,y1,l1)
	graph.set_edge_label(x2,y2,l2)


def setted_angles(G):
	result=[]
	for u in G.vertices():
		for e in G.edges_incident(u):
			for f in G.edges_incident(u):
				if e != f:
					if e[2]==f[2]:
						result.append((e,f,1))
					else:
						result.append((e,f,-1))
	return result

def local_subgraph(G,u, d):
	distances=G.distance_all_pairs()[u]
	sub_d = []
	for i in distances:
		if (distances[i] <= d):
			sub_d.append(i)
	H = G.subgraph(sub_d)
	return H



def full_search(graph, cont=0, oldDecompositions=[]):
	#recursion that runs through the graph until it finds a path decomposition
	#returns (moves, True) if it finds, otherwise (moves, False)
	mov=[]
	hangingEdges = takeHangingEdges(graph)
	if (hangingEdges == True):
		#print("Old decompositions", len(oldDecompositions))
		cont = cont + 1
		return cont

	pMoves = possibleMoves(graph, hangingEdges)
	var = False
	oldDecompositions.append(graph.edges())
	for i in pMoves:
		move(graph, i)
		dec = graph.edges()
		if (dec in oldDecompositions):
			unmove(graph, i)
		else:
			cont = full_search(graph, cont, oldDecompositions)

	return cont



def full_test(G):
	b = []
	for M in G.perfect_matchings():
		for i in M:
			G.delete_edge(i)
		petersen = G.two_factor_petersen()
		for i in M:
			G.add_edge(i)
		H = Graph(G)
		canonicalDecomposition(H, M, petersen)
		cont = full_search(H, 0, [])
		b.append(cont)
	
		aux0 = petersen[0]
		aux1 = petersen[1]
		petersen = [aux1, aux0]
		H = Graph(G)
		canonicalDecomposition(H, M, petersen)
		cont = full_search(H, 0, [])
		b.append(cont)
	
	return b

###########

decompositions = {}

def full_search_dic(graph, currentState = [], decompositions={}, oldDecompositions=[]):
	#recursion that runs through the graph until it finds a path decomposition
	#returns (moves, True) if it finds, otherwise (moves, False)
	mov=[]
	hangingEdges = takeHangingEdges(graph)
	if (hangingEdges == True):
		#print("Old decompositions", len(oldDecompositions))
		decompositions[currentState] = 10
		return decompositions

	pMoves = possibleMoves(graph, hangingEdges)
	var = False
	oldDecompositions.append(graph.edges())
	for i in pMoves:
		move(graph, i)
		angles = setted_angles(graph)
		X = Graph(angles)
		A = X.weighted_adjacency_matrix()
		poly = A.charpoly()
		if not(poly in decompositions):
			decompositions[poly] = 0
		else:
			print('repetido')
		dec = graph.edges()
		if (dec in oldDecompositions):
			unmove(graph, i)
		else:
			decompositions = full_search_dic(graph, poly, decompositions, oldDecompositions)

	return decompositions


def full_test_dic(G):
	b = {}
	for M in G.perfect_matchings():
		for i in M:
			G.delete_edge(i)
		petersen = G.two_factor_petersen()
		for i in M:
			G.add_edge(i)
		H = Graph(G)
		canonicalDecomposition(H, M, petersen)
		angles = setted_angles(H)
		X = Graph(angles)
		A = X.weighted_adjacency_matrix()
		poly = A.charpoly()
		b = full_search_dic(H, poly, b, [])
		
	
		aux0 = petersen[0]
		aux1 = petersen[1]
		petersen = [aux1, aux0]
		H = Graph(G)
		canonicalDecomposition(H, M, petersen)
		angles = setted_angles(H)
		X = Graph(angles)
		A = X.weighted_adjacency_matrix()
		poly = A.charpoly()
		b = full_search_dic(H, poly, b, [])
	return b

'''
decompositions = {}

G = graphs.RandomRegular(5, 16)

decompositions = full_test_dic(G) 

cont = 0

for i in decompositions:
    if (decompositions[i] == 10):
	    cont += 1
         
cont

len(decompositions)
'''
###random list choose
#move = pMoves[floor(uniform(0, len(list1)))]

def random_search_dic(graph, currentState = [], decompositions={}, oldDecompositions=[]):
	#recursion that runs through the graph until it finds a path decomposition
	#returns (moves, True) if it finds, otherwise (moves, False)
	var = False
	reward = 0
	episodes = 0
	hangingEdges = takeHangingEdges(graph)
	if (hangingEdges == True):
		reward = 1
		decompositions[currentState] = reward
		print("hang ", hangingEdges, decompositions[currentState])
		return decompositions, True, reward
	pMoves = possibleMoves(graph, hangingEdges)
	oldDecompositions.append(graph.edges())
	for episodes in range(100):
		if pMoves == []:
			break
		i = pMoves[floor(uniform(0, len(pMoves)))]
		move(graph, i)
		angles = setted_angles(graph)
		X = Graph(angles)
		A = X.weighted_adjacency_matrix()
		poly = A.charpoly()
		if not(poly in decompositions):
			decompositions[poly] = reward
		dec = graph.edges()
		if (dec in oldDecompositions):
			unmove(graph, i)
		else:
			decompositions, var, reward  = random_search_dic(graph, poly, decompositions, oldDecompositions)
			if (var==True):
				reward = reward/len(pMoves)
				decompositions[poly] = reward
				return decompositions, var, reward

	return decompositions, var, reward

def random_test_dic(G):
	d = {}
	b = False
	r = 0
	for M in G.perfect_matchings():
		for i in M:
			G.delete_edge(i)
		petersen = G.two_factor_petersen()
		for i in M:
			G.add_edge(i)
		H = Graph(G)
		canonicalDecomposition(H, M, petersen)
		angles = setted_angles(H)
		X = Graph(angles)
		A = X.weighted_adjacency_matrix()
		poly = A.charpoly()
		d, b, r = random_search_dic(H, poly, d, [])
		
	
		aux0 = petersen[0]
		aux1 = petersen[1]
		petersen = [aux1, aux0]
		H = Graph(G)
		canonicalDecomposition(H, M, petersen)
		angles = setted_angles(H)
		X = Graph(angles)
		A = X.weighted_adjacency_matrix()
		poly = A.charpoly()
		d, b, r  = random_search_dic(H, poly, d, [])
		
	
	return b, d

"""
start = time.time()
b, d = random_test_dic(G)
end = time.time()"""

def local_random_search_dic(graph, d, currentState = [], decompositions={}, oldDecompositions=[]):
	#recursion that runs through the graph until it finds a path decomposition
	#returns (moves, True) if it finds, otherwise (moves, False)
	var = False
	reward = 0
	episodes = 0

	hangingEdges = takeHangingEdges(graph)
#	print("took hanging edges")
	if (hangingEdges == True):
		print("is a decomposition")
		reward = 1
#		decompositions[currentState] = reward
		return decompositions, True, reward
	pMoves = possibleMoves(graph, hangingEdges)
	oldDecompositions.append(graph.edges())
	for episodes in range(100):
#		print("entered episodes")
		if pMoves == []:
			break
		i = pMoves[floor(uniform(0, len(pMoves)))]
		move(graph, i)
		u = conection_vertex(i)
		subgraph = local_subgraph(graph,u, d)
		angles = setted_angles(subgraph)
		X = Graph(angles)
		X = X.canonical_label()
		A = X.weighted_adjacency_matrix()
#		print("constructed matrix")
#		poly = A.charpoly()
		poly=0
		tupleA=matrix_to_tuple(A)
		
		if (tupleA in decompositions) == False:
			decompositions[tupleA]=[0,1]
#			print("added item to dic")
		
#		if not(poly in decompositions):
#			decompositions[poly] = reward
		
		dec = graph.edges()
		if (dec in oldDecompositions):
			unmove(graph, i)
			print("entrou aqui nessa")
			print(decompositions)
		else:
			print("mas antes entrou aqui")
			decompositions, var, reward  = local_random_search_dic(graph, d, poly, decompositions, oldDecompositions)
			if (var==True):
				print("ENTROU AQUI CARAI")
#				reward = reward/len(pMoves)
#				decompositions[poly] = reward
				decompositions[tupleA][0]+=1
				return decompositions, var, reward
	return decompositions, var, reward

def local_random_test_dic(G):
	decompositions = {}
	b = False
	r = 0
	d = 2
	for M in G.perfect_matchings():
		for i in M:
			G.delete_edge(i)
		petersen = G.two_factor_petersen()
		for i in M:
			G.add_edge(i)
		H = Graph(G)
		canonicalDecomposition(H, M, petersen)
		angles = setted_angles(H)
		X = Graph(angles)
		A = X.weighted_adjacency_matrix()
		poly = A.charpoly()
		decompositions, b, r = local_random_search_dic(H, d, poly, decompositions, [])
		
	
		aux0 = petersen[0]
		aux1 = petersen[1]
		petersen = [aux1, aux0]
		H = Graph(G)
		canonicalDecomposition(H, M, petersen)
		angles = setted_angles(H)
		X = Graph(angles)
		A = X.weighted_adjacency_matrix()
		poly = A.charpoly()
		decompositions, b, r  = local_random_search_dic(H, d, poly, decompositions, [])
		
		if b:
			break
	
	return decompositions,b

def conection_vertex(pair):
	if (pair[0][0]==pair[1][0]):
		return pair[0][0]
	elif (pair[0][0]==pair[1][1]):
		return pair[0][0]
	else:
		return pair[0][1]
		
def matrix_to_tuple(A):
	result=()
	for i in A:
		result+=tuple(i)
	return result

# Prossimo passo unificar as buscas ou selecionar as mais importantes
