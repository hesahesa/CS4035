from sklearn.tree import DecisionTreeClassifier
import numpy as np
from sklearn import cross_validation
from unbalanced_dataset import SMOTE
import pandas as pd

df = pd.read_csv('after_preprocess.csv', parse_dates=['bookingdate', 'creationdate'])
# ['txid', 'bookingdate', 'issuercountrycode', 'txvariantcode', 'bin',
#  'amount', 'currencycode', 'shoppercountrycode', 'shopperinteraction',
#  'simple_journal', 'cardverificationcodesupplied', 'cvcresponsecode',
#  'creationdate', 'accountcode', 'mail_id', 'ip_id', 'card_id']

attributes = ['is_same_currency_shopper', 'is_same_issuer_shopper', 'relative_amount', 'average_amount_daily']
label = 'true_label'

X = df.ix[:, attributes].values
y = df['true_label'].values

print(type(X))
print(type(y))

print("ratio before")
num_one = df[df['true_label'] == 1]
num_zero = df[df['true_label'] == 0]
ratio = float(num_zero.size) / float(num_one.size)
print(ratio)

smote = SMOTE(ratio=9, verbose=False, kind='regular')
smox, smoy = smote.fit_transform(X, y)

print("ratio after")
num_one = np.count_nonzero(smoy == 1)
num_zero = np.count_nonzero(smoy == 0)
ratio = float(num_zero) / float(num_one)
print(ratio)

clf = DecisionTreeClassifier()

scores = cross_validation.cross_val_score(clf, smox, smoy, cv=10, scoring='f1')
print("F1: %0.2f (+/- %0.2f)" % (scores.mean(), scores.std() * 2))

#clf.fit(X[:-1], y[:-1])

#print(clf.predict(X[-1:]))
#print(y[-1:])