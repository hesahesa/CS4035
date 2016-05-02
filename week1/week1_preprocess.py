import pandas as pd

df = pd.read_csv('data_for_student_case.csv', parse_dates=['bookingdate', 'creationdate'])
# ['txid', 'bookingdate', 'issuercountrycode', 'txvariantcode', 'bin',
#  'amount', 'currencycode', 'shoppercountrycode', 'shopperinteraction',
#  'simple_journal', 'cardverificationcodesupplied', 'cvcresponsecode',
#  'creationdate', 'accountcode', 'mail_id', 'ip_id', 'card_id']

# ignore data with simple_journal == refused
df = df[df['simple_journal'] != 'Refused']

lookup_avg_daily = {}

# create new attributes
def isCurrencySameWithShopper(row):
    if ((row['currencycode'] == 'AUD' and row['shoppercountrycode'] == 'AU') or
        (row['currencycode'] == 'GBP' and row['shoppercountrycode'] == 'GB') or
        (row['currencycode'] == 'MXN' and row['shoppercountrycode'] == 'MX') or
        (row['currencycode'] == 'NZD' and row['shoppercountrycode'] == 'NZ') or
        (row['currencycode'] == 'SEK' and row['shoppercountrycode'] == 'SE')):
        return 1
    else:
        return 0

def isIssuerSameWithShopper(row):
    if row['issuercountrycode'] == row['shoppercountrycode']:
        return 1
    else:
        return 0

def getRelativeAmount(row):
    currAmount = row['amount']
    meanamount = row['average_amount_daily']
    if row['currencycode'] == 'AUD':
        upperthreshold = meanamount + (threeshold_AUD * meanamount)
        lowerthreeshold = meanamount - (threeshold_AUD * meanamount)
    elif row['currencycode'] == 'GBP':
        upperthreshold = meanamount + (threeshold_GBP * meanamount)
        lowerthreeshold = meanamount - (threeshold_GBP * meanamount)
    elif row['currencycode'] == 'MXN':
        upperthreshold = meanamount + (threeshold_MXN * meanamount)
        lowerthreeshold = meanamount - (threeshold_MXN * meanamount)
    elif row['currencycode'] == 'NZD':
        upperthreshold = meanamount + (threeshold_NZD * meanamount)
        lowerthreeshold = meanamount - (threeshold_NZD * meanamount)
    elif row['currencycode'] == 'SEK':
        upperthreshold = meanamount + (threeshold_SEK * meanamount)
        lowerthreeshold = meanamount - (threeshold_SEK * meanamount)

    if currAmount <= upperthreshold and currAmount >= lowerthreeshold:
        return 0
    elif currAmount > upperthreshold:
        return currAmount - upperthreshold
    elif currAmount < lowerthreeshold:
        return  currAmount - lowerthreeshold
    else:
        return currAmount - meanamount

def isValidTrx(row):
    if row['simple_journal'] == 'Settled':
        return 1
    elif row['simple_journal'] == 'Chargeback':
        return 0
    else:
        return 0 # should not happen

def getDailyAverage(row):
    creationdate_dateonly = row['creationdate_dateonly']
    currency = row['currencycode']

    if (currency, creationdate_dateonly) in lookup_avg_daily:
        return lookup_avg_daily[(currency, creationdate_dateonly)]
    else:
        tmp = df[df['currencycode'] == currency]
        tmp = tmp[tmp['creationdate_dateonly'] == creationdate_dateonly]

        retval = tmp['amount'].mean(axis=0)
        lookup_avg_daily[(currency, creationdate_dateonly)] = retval
        return retval

def parseCreationDate(row):
    return row['creationdate'].date()

def parseHour(row):
    return row['creationdate'].time().hour

# threeshold from mean of each currency, free parameter chosen by user
threeshold_AUD = 0
threeshold_GBP = 0
threeshold_MXN = 0
threeshold_NZD = 0
threeshold_SEK = 0

print("generate 1")
df['creationdate_dateonly'] = df.apply(lambda row: parseCreationDate(row), axis=1)
print("generate 2")
df['is_same_currency_shopper'] = df.apply(lambda row: isCurrencySameWithShopper(row), axis=1)
print("generate 3")
df['is_same_issuer_shopper'] = df.apply(lambda row: isIssuerSameWithShopper(row), axis=1)
print("generate 4")
df['average_amount_daily'] = df.apply(lambda row: getDailyAverage(row), axis=1)
print("generate 5")
df['relative_amount'] = df.apply(lambda row: getRelativeAmount(row), axis=1)
print("generate 6")
df['transaction_hour'] = df.apply(lambda row: parseHour(row), axis=1)
print("generate 7")
df['true_label'] = df.apply(lambda row: isValidTrx(row), axis=1)

print(df.columns)
df.to_csv("after_preprocess.csv", encoding="utf-8")