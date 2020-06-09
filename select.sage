# -*- coding: utf-8 -*-

load('functions.sage')


def auxiliaryGraph(graph):
    edges = graph.edges()
    aux = 0
    for i in edges:
        if (i[2] > aux):
            aux = i[2]
    aux += 1
    H = Graph(aux)

    hangingEdges = takeHangingEdges(graph)
    pMoves = possibleMoves(graph,hangingEdges)
    for i in pMoves:
        H.add_edge(i[0][2],i[1][2])
    return H

def hangEdges(graph):
    hang = takeHangingEdges(graph)
    if (hang == True):
        return True
    if (graph.order() == len(hang)):
        return True
    return False

def tester(graph, mov):
    dic = {}
    aux = []
    #aux.append(triangleNumber(graph))
    #aux.append(squareNumber(graph))
    a,b,c=badsCounter(graph)
    aux.append(a)
    aux.append(b)
    aux.append(c)
    aux.append(hangEdges(graph))
    aux.append(hangConnectionVertexs(graph))
    dic[0] = aux
    cont = 1
    for i in mov:
        aux = []
        move(graph, i)
        #aux.append(triangleNumber(graph))
        #aux.append(squareNumber(graph))
        a,b,c=badsCounter(graph)
        aux.append(a)
        aux.append(b)
        aux.append(c)
        aux.append(hangEdges(graph))
        aux.append(hangConnectionVertexs(graph))
        dic[cont] = aux
        cont += 1
        #switch (hypothesis){
        #    case 0: 
        #}
    return dic

def dictionaryMaker(graph):
    dic = {}
    edges=graph.edges()
    n = graph.order()
    for i in range(n/2):
        dic[i]=[]
    for i in edges:
        dic[i[2]].append(i)
    return dic


def badsCounter(graph):
    dic = dictionaryMaker(graph)
    triangles = 0
    squares = 0
    k4minuses = 0
    for i in dic:
        H = Graph(dic[i])
        triangles_in_H=H.triangles_count()
        if (triangles_in_H == 1):
            triangles += 1
        if (triangles_in_H == 2):
            k4minuses += 1
        aux = 0
        for j in H.degree():
            if (j==1):
                aux +=1
        if (aux==1 and triangles_in_H==0):
            squares += 1
    return triangles,squares,k4minuses


def componentElements(graph, vertexs):
    dic = {}
    edges=graph.edges()
    n = graph.order()
    cont = 0
    for i in range(n/2):
        dic[i]=[]
    for i in edges:
        dic[i[2]].append(i)
    edgesColorGraph = []
    for i in vertexs:
        for j in dic[i]:
            edgesColorGraph.append(j)
    colorGraph = Graph(edgesColorGraph)
    return colorGraph


def isnumber(value):
    try:
        int(value)
    except ValueError:
        return False
    return True


def searchALT_recusion_treeALT(graph,T,father, oldDecompositions=[], auxiliary = {},decomposition_list={}):
    #recursion that runs through the graph until it finds a path decomposition
    #returns (moves, True) if it finds, otherwise (moves, False)
    mov=[]
    hangingEdges = takeHangingEdges(graph)
    if(hangingEdges==True):
        edges = graph.edges()
        aux = 0
        for i in edges:
            if (i[2] > aux):
                aux = i[2]
        aux += 1
        H = Graph(aux)
        auxiliary[father] = H
        return mov, True, auxiliary, decomposition_list

    H = auxiliaryGraph(graph)
    #if (father==0):
        #H = auxiliaryGraph(graph)
        #auxiliary[0] = H
    auxiliary[father] = H


    pMoves = possibleMoves(graph,hangingEdges)
    var = False
    #oldDecompositions.append(graph.edges())
    new_edges=[]
	for e in graph.edges():
		new_edges.append(e)
	oldDecompositions.append(new_edges)
    decomposition_list[father]=Graph(graph.edges())
    for i in pMoves:
        move(graph, i)
        dec = graph.edges()
        isold = dec in oldDecompositions
        if not isold:
            print("move " + str(i))
#            print ("is an old decomposotion: unmoving")
        a,b,c=badsCounter(graph)
        if ((not isold) and isTrailDecomposition(graph) and (c==0)):            
            v=T.add_vertex()
            T.add_edge(v,father)
            #H = auxiliaryGraph(graph)
            #auxiliary[v] = H

            mov, var, auxiliary, decomposition_list = searchALT_recusion_treeALT(graph,T,v,oldDecompositions, auxiliary,decomposition_list)
            if (var==True):
                mov.insert(0,i)
                return mov, var, auxiliary, decomposition_list
        unmove(graph, i)
#        print ("unmove " + str(i))
    return mov, var, auxiliary, decomposition_list


def level1(G, M, allow_k4minuses = True, allow_triangles = True, allow_squares = True, allow_connection_vertex_whithout_hanging_edge = True):
    global aux

    #if (decomposition == allow_k4minuses):
        #nok4minusCanonicalDecomposition(G)
    
    #canonicalDecomposition(G)
    #nok4minusCanonicalDecomposition(G)
    #allowCanonicalDecomposition(G, allow_k4minuses, allow_triangles, allow_squares, allow_connection_vertex_whithout_hanging_edge)
    for i in M:
        G.delete_edge(i)
    petersen = G.two_factor_petersen()
    for i in M:
        G.add_edge(i)
    canonicalDecomposition(G, M, petersen)
    X=Graph(G)
    mov = []
    var = False
    auxiliary = {}
    T = Graph()
    father=T.add_vertex()
    mov, var, auxiliary, decomposition_list = searchALT_recusion_treeALT(G,T,father,[])
    
    #canonicalDecomposition(G)
    #nok4minusCanonicalDecomposition(G)
    testes = tester(X, mov)
    print(testes)

    aux = auxiliary
    #T.show(layout="tree",tree_root=0)
    T.show()

    #T.plot(layout="tree",tree_root=0,save_pos=True)
    while True:
        print("\nPara sair digite \"s\". \nDigite o vértice: ")
        vertex = input()
        if (not(isnumber(vertex))):
            break
        vertex = int(vertex)
        if (vertex >= 0 and vertex <= T.order()):
            X = aux[vertex]
            X.show()
            #print(G.edges())
            level2(decomposition_list[vertex])
        else:
            break
    #print_click_pos(T)

def level2(G):
    while True:
        print("\nPara sair digite \"s\". \nDigite uma lista de vértices: ")
        vertexs = input()
        if (vertexs == "S" or vertexs == "s"):
            break
        colorGraph = componentElements(G, vertexs)
        colorGraph.show(color_by_label=true,layout="circular")


def connectionVertexsL(graph):
    connectionVertexsList = []
    dic = dictionaryMaker(graph)
    for i in dic:
        H = Graph(dic[i])
        for j in H.vertices():
            if (mod(len(H.neighbors(j)),2)==1):
                for k in H.neighbors(j):
                    if (k not in connectionVertexsList):
                        connectionVertexsList.append(k)
    return connectionVertexsList

def hangConnectionVertexs(graph):
    hang = takeHangingEdges(graph)
    connectionVertexsList = connectionVertexsL(graph)
    if (hang == True):
        return "fim"
    for i in connectionVertexsList:
        if (i not in hang):
            return False
    return True