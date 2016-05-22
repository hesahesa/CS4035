import math
import pandas as pd
import bitarray
import pymmh3 as mmh3


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
        for seed in range(1,self.hash_count):
            result = mmh3.hash(string, seed) % self.size
            self.bit_array[result] = 1

    def lookup(self, string):
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
            bit_array = bitarray(size)
            bit_array.setall(0)
            self.arrays[i] =  bit_array

    def add(self, string, val):
        for seed in range(1,self.hash_count):
            result = mmh3.hash(string, seed) % self.size
            self.arrays[seed][result] = val

    def lookup(self, string):
        vals = []
        for seed in range(1,self.hash_count):
            result = mmh3.hash(string, seed) % self.size
            val = self.arrays[seed][result]
            vals.append(val)
        return min(vals)

df = loadDataStream()

for k in [10,100,1000]:
    c = applyFREQUENT(df,10)
    print(c)

num_rec = len(df)
half_rec = math.floor(num_rec/2)

df_train = df.loc[0:half_rec]
df_test = df.loc[(half_rec+1):(num_rec-1)]

for size in [10,100,1000]:
    for hash_count in [3,5,7]:
        bloom = BloomFilter(size,hash_count)
        for rec in df_train['euro']:
            bloom.add(rec)

        lookup = {}
        for rec in df_test['euro']:
            lookup[rec] = bloom.lookup(rec)

        print(lookup)

for size in [10,100,1000]:
    for hash_count in [3,5,7]:
        minsketch = CountMinSketch(size,hash_count)
        for rec in df_train['euro']:
            minsketch.add(rec)

        lookup = {}
        for rec in df_test['euro']:
            lookup[rec] = bloom.lookup(rec)

        print(lookup)