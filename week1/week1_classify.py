from sklearn.tree import DecisionTreeClassifier
from sklearn.svm import SVC
from sklearn.naive_bayes import MultinomialNB
from sklearn.neighbors import KNeighborsClassifier
from sklearn.metrics import confusion_matrix
import numpy as np
from sklearn import cross_validation
from unbalanced_dataset import SMOTETomek  # pip install git+https://github.com/fmfn/UnbalancedDataset
import pandas as pd

df = pd.read_csv('after_preprocess.csv', parse_dates=['bookingdate', 'creationdate'])
# ['txid', 'bookingdate', 'issuercountrycode', 'txvariantcode', 'bin',
#  'amount', 'currencycode', 'shoppercountrycode', 'shopperinteraction',
#  'simple_journal', 'cardverificationcodesupplied', 'cvcresponsecode',
#  'creationdate', 'accountcode', 'mail_id', 'ip_id', 'card_id']

attributes = ['is_same_currency_shopper', 'is_same_issuer_shopper', 'relative_amount', 'average_amount_daily',
              'transaction_hour']
label = 'true_label'

X = df.ix[:, attributes].values
y = df['true_label'].values

print(type(X))
print(type(y))

print("ratio before")
num_one = np.count_nonzero(y == 1)
num_zero = np.count_nonzero(y == 0)
ratio = float(num_zero) / float(num_one)
print(ratio)

#X_train, X_test, y_train, y_test = cross_validation.train_test_split(X, y, train_size=0.8)

smote = SMOTETomek(ratio=90, verbose=False)
smox, smoy = smote.fit_transform(X, y)

print("ratio after")
num_one = np.count_nonzero(smoy == 1)
num_zero = np.count_nonzero(smoy == 0)
ratio = float(num_zero) / float(num_one)
print(ratio)

#clf = DecisionTreeClassifier()
#clf = SVC()
#clf = MultinomialNB()
clf = KNeighborsClassifier(n_neighbors=1)

#clf.fit(smox, smoy)
#predicted = clf.predict(X_test)

#print(confusion_matrix(y_test, predicted, labels=[1, 0]))

scores = cross_validation.cross_val_score(clf, smox, smoy, cv=10, scoring='precision')
print("precision: %0.2f (+/- %0.2f)" % (scores.mean(), scores.std() * 2))

scores = cross_validation.cross_val_score(clf, smox, smoy, cv=10, scoring='recall')
print("recall: %0.2f (+/- %0.2f)" % (scores.mean(), scores.std() * 2))

scores = cross_validation.cross_val_score(clf, smox, smoy, cv=10, scoring='accuracy')
print("accuracy: %0.2f (+/- %0.2f)" % (scores.mean(), scores.std() * 2))

scores = cross_validation.cross_val_score(clf, smox, smoy, cv=10, scoring='f1')
print("F1: %0.2f (+/- %0.2f)" % (scores.mean(), scores.std() * 2))

#clf.fit(X[:-1], y[:-1])

#print(clf.predict(X[-1:]))
#print(y[-1:])