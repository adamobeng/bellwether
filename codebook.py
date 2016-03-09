import urllib.request
from bs4 import BeautifulSoup

soup = BeautifulSoup(urllib.request.urlopen(
    'http://www.icpsr.umich.edu/icpsrweb/ICPSR/ssvd/studies/08611/variables?q=PRES&paging.rows=400&sortBy=7'))

rows = soup.find_all('div', class_='searchResult row')

oldyear = '1840'
party_names = []
party_columns = []
out = []
for r in rows:
    variable = r.find('div', 'col-sm-2 col-xs-10').text
    label = r.find('div', 'col-sm-9 col-xs-12').find('p').text.strip()
    year, label = label.split(maxsplit=1)
    label = label[5:].strip()
    if label in ('TTL VOTE', 'T/O'):
        continue
    label = label.replace(' ', '_')
    if year != oldyear:
        outrow = ''
        outrow += 'list(\n\tyear =%s,\n' % year
        outrow += '\tparty.names = c(%s),\n' % ','.join("'%s'" % x for x in party_names)
        outrow += '\tparty.columns = c(%s)\n' % ','.join("'%s'" % x for x in party_columns)
        outrow += ')'
        out.append(outrow)
        oldyear = year
        party_names = []
        party_columns = []
    party_names.append(label)
    party_columns.append(variable)

open('elections.columns.list.R', 'w').write('elections.columns.list = list(\n%s\n)' % ',\n'.join(out))
