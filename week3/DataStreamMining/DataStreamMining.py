import math
import pandas as pd
from bitarray import bitarray
import pymmh3 as mmh3
import operator


def loadDataStream():
    df = pd.read_csv("data_for_student_case.csv")
    df['bookingdate']  = pd.to_datetime(df['bookingdate'])
    df['creationdate'] = pd.to_datetime(df['creationdate'])
    currency_dict = { 'MXN': 0.01*0.05, 'SEK': 0.01*0.11, 'AUD': 0.01*0.67, 'GBP': 0.01*1.28, 'NZD': 0.01*0.61 }
    df['euro'] = list(map(lambda x,y: currency_dict[y]*x, df['amount'],df['currencycode']))
    df['euro'] = df['euro'].astype(int)
    df_sort_creation = df.sort_values(by = 'creationdate', ascending = True)
    grouped = df_sort_creation[ ['creationdate', 'simple_journal','euro'] ].groupby(df_sort_creation['euro'])
    print(grouped.count().sort_values('creationdate', ascending = False).head(n = 10))

    return df_sort_creation


def applyFREQUENT(df,k):
    c = {}
    T = []

    for i in df['euro']:
        if(i in T):
            c[i] = c[i]+1
        elif len(T) < k-1:
            T.append(i)
            c[i] = 1
        else:
            for j in T:
                c[j] = c[j] - 1
                if(c[j]==0):
                    T.remove(j)
                    del(c[j])

    return c


class BloomFilter:
    def __init__(self, size, hash_count):
        self.size = size
        self.hash_count = hash_count
        self.bit_array = bitarray(size)
        self.bit_array.setall(0)

    def add(self, string):
        string = str.encode(str(string))
        for seed in range(1,self.hash_count):
            result = mmh3.hash(string, seed) % self.size
            self.bit_array[result] = 1

    def lookup(self, string):
        string = str.encode(str(string))
        for seed in range(1,self.hash_count):
            result = mmh3.hash(string, seed) % self.size
            if self.bit_array[result] == 0:
                return 0
        return 1


class CountMinSketch:
    def __init__(self, size, hash_count):
        self.size = size
        self.hash_count = hash_count
        self.arrays = {}
        for i in range(1,self.hash_count):
            val_array = [0]*size
            self.arrays[i] =  val_array

    def add(self, string, val):
        string = str.encode(str(string))
        for seed in range(1,self.hash_count):
            result = mmh3.hash(string, seed) % self.size
            self.arrays[seed][result] = val + self.arrays[seed][result]

    def lookup(self, string):
        string = str.encode(str(string))
        vals = []
        for seed in range(1,self.hash_count):
            result = mmh3.hash(string, seed) % self.size
            val = self.arrays[seed][result]
            vals.append(val)
        return min(vals)

df = loadDataStream()

# Test FREQUENT
for k in [10,100,1000]:
    c = applyFREQUENT(df,k)
    sorted_c = sorted(c.items(), key=operator.itemgetter(1))
    sorted_c.reverse()
    print("FREQUENT with k="+str(k)+": "+str(sorted_c[0:10]))

# Test BLOOM
# separate the data into trainset and test set
num_rec = len(df)
half_rec = math.floor(num_rec/2)

df_train = df.loc[0:half_rec]
df_test = df.loc[(half_rec+1):(num_rec-1)]

#compare the values in test set
unique_train = set(df_train['euro'])
unique_test = set(df_test['euro'])
correct_result = {}
for check_test in unique_test:
    if(check_test in unique_train):
        correct_result[check_test] = 1
    else:
        correct_result[check_test] = 0

# hash the train set using BLOOM
for size in [10,100,1000, 10000]:
    for hash_count in [3,6,10,15]:
        bloom = BloomFilter(size,hash_count)
        for rec in df_train['euro']:
            bloom.add(rec)

        #lookup each value in test set using BLOOM
        lookup = {}
        for rec in unique_test:
            lookup[rec] = bloom.lookup(rec)

        eval_BLOOM = {}
        eval_BLOOM['true_positive'] = 0
        eval_BLOOM['true_negative'] = 0
        eval_BLOOM['false_positive'] = 0
        eval_BLOOM['false_negative'] = 0

        for check_test in unique_test:
            if(lookup[check_test]==correct_result[check_test]):
                if(lookup[check_test]==1):
                    eval_BLOOM['true_positive'] = eval_BLOOM['true_positive'] + 1
                else:
                    eval_BLOOM['true_negative'] = eval_BLOOM['true_negative'] + 1
            else:
                if (lookup[check_test] == 1):
                    eval_BLOOM['false_positive'] = eval_BLOOM['false_positive'] + 1
                else:
                    eval_BLOOM['false_negative'] = eval_BLOOM['false_negative'] + 1
        for cat in eval_BLOOM:
            eval_BLOOM[cat] = eval_BLOOM[cat]/num_rec

        print("BLOOM evaluation with size="+str(size)+" and hash="+str(hash_count)+": "+str(eval_BLOOM))

# test the Count Min Sketch
for size in [100,1000,10000,100000]:
    for hash_count in [3,6,10,15]:
        minsketch = CountMinSketch(size,hash_count)
        for rec in df['euro']:
            minsketch.add(rec,1)

        lookup = {}
        unique_values = set(df['euro'])
        for rec in unique_values:
            lookup[rec] = minsketch.lookup(rec)

        sorted_freq = sorted(lookup.items(), key=operator.itemgetter(1))
        sorted_freq.reverse()
        print("Top 10 frequencies with size="+str(size)+" and hash="+str(hash_count)+": "+str(sorted_freq[0:10]))


