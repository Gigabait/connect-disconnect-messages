#!/usr/bin/env python35
import os
import urllib.request

# http://webmasters.stackexchange.com/a/34663

RIR_Stats = {
	"apnic": [
		"ftp://ftp.apnic.net/pub/stats/apnic/delegated-apnic-latest",
		"ftp://ftp.apnic.net/pub/stats/apnic/delegated-apnic-extended-latest",
		#"ftp://ftp.apnic.net/pub/stats/apnic/assigned-apnic-latest" ??
	],

	"afrnic": [
		"ftp://ftp.afrinic.net/stats/afrinic/delegated-afrinic-latest",
		"ftp://ftp.afrinic.net/stats/afrinic/delegated-afrinic-extended-latest"
	],

	"arin": [
		"ftp://ftp.arin.net/pub/stats/arin/delegated-arin-extended-latest"
	],

	"ripencc": [
		"ftp://ftp.ripe.net/pub/stats/ripencc/delegated-ripencc-latest",
		"ftp://ftp.ripe.net/pub/stats/ripencc/delegated-ripencc-extended-latest"
	],

	"lacnic": [
		"ftp://ftp.lacnic.net/pub/stats/lacnic/delegated-lacnic-latest",
		"ftp://ftp.lacnic.net/pub/stats/lacnic/delegated-lacnic-extended-latest"
	]
}

if not os.path.exists('data'):
	print('Creating "data" directory')
	os.makedirs('data')

files = []

for k in RIR_Stats:
	print('In ' + k)

	for s in RIR_Stats[k]:
		print('\tChecking ' + s)
		f = ('data/' + s.split('/')[-1])

		if not os.path.exists(f):
			print('Downloading ' + f)
			files.append(urllib.request.urlretrieve(s, f))

	print('')

print('All data files downloaded')
