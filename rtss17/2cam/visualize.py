import csv

print "--------------------------------------------------------------"
print " Verification with 20 frames, NON satisfied"
print "--------------------------------------------------------------"

with open('r20f.csv', 'rb') as csvfile:
  spamreader = csv.reader(csvfile, delimiter='\t')
  for row in spamreader:
    if row[3] != '1.0':
      print row
      
print "--------------------------------------------------------------"
print " Verification with 30 frames, NON satisfied"
print "--------------------------------------------------------------"
      
with open('r30f.csv', 'rb') as csvfile:
  spamreader = csv.reader(csvfile, delimiter='\t')
  for row in spamreader:
    if row[3] != '1.0':
      print row
