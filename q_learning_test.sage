import os
import time
import multiprocessing
import pickle

load("functions.sage")

bads = []


arq = open('q_learning3.txt','rb')
decompositions = pickle.load(arq)
arq.close()


def q_learning_test(x, d, epsilon, decompositions = {}):
    G = Graph(x)
    won = False
    for M in G.perfect_matchings():
        for i in M:
            G.delete_edge(i)
        petersen = G.two_factor_petersen()
        for i in M:
            G.add_edge(i)
        H = Graph(G)
        canonicalDecomposition(H, M, petersen)
        decompositions, won, lost, r = q_learning(H, d, epsilon, decompositions, [])
        
    
        aux0 = petersen[0]
        aux1 = petersen[1]
        petersen = [aux1, aux0]
        H = Graph(G)
        canonicalDecomposition(H, M, petersen)
        decompositions, won, lost, r  = q_learning(H, d, epsilon, decompositions, [])
    
        if won:
            break
    
    return won, decompositions


def short_test(path, decompositions):
    graphs_file= open(path)
    d = 1
    epsilon = 0.1
    bads_graphs = []
    inicio = time.time()
    for x in graphs_file:
        won, decompositions = q_learning_test(x, d, epsilon, decompositions)
        if won==False:
            bads_graphs.append(x)
    fim = time.time()
    print(fim - inicio)



<<<<<<< HEAD
#short_test('graphs/5regular8-all.g6', decompositions)
=======
short_test('graphs/5regular12-all.g6', decompositions)
>>>>>>> bf9fccb16eef1a0bbb75c5e7cd4292f1492ccc30
