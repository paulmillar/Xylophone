#!/usr/bin/python

import sys
from ldif import LDIFParser, LDIFWriter, LDIFRecordList

class LDIFVerifier():
    """
    Check that two LDIF files contain equivalent LDAP information.
    """

    def __init__( self, in_file_1, in_file_2):
        """
        Parameters:
        in_file_1
            filename of first file to read
        in_file_2
            filename of second file to read
        """
        self._src_1 = LDIFRecordList(open(in_file_1))
        self._src_2 = LDIFRecordList(open(in_file_2))

    def findRecord( self, list, dn):
        """
        Find a record with given dn, or None if no such record exists.
        """
        for record in list:
            recordDn,recordValueSet = record
            if recordDn == dn:
                return record
        return None

    def emitDifferingValues( self, valSet1, valSet2):
        """
        Emit all differences between two value-sets
        """
        #union = valSet1 + ...
        for k , values1 in valSet1.iteritems():
            values2 = valSet2[k]
            if values1 != values2:
                print "  " + k + ": " + str(values1) + " != " + str(values2)

    def emitDifferences( self, list1, list2):
        """
        Emit all differences between list1 and list2
        """
        #union = list1 + list2
        for record1 in list1:
            dn,valueSet1 = record1
            record2 = self.findRecord( list2, dn)
            if record2:
                dn2,valueSet2 = record2
                if( valueSet1 != valueSet2):
                    print dn + ": "
                    self.emitDifferingValues( valueSet1, valueSet2)
            else:
                print "Missing second corresponding"
                self.printRecord( record1)


    def printRecord( self, record):
        """
        Print a record
        """
        dn,value = record
        print "dn: " + dn
        for k, v in value.iteritems():
            print "  " + k + ": " + v [0]
            if( len(v) > 1):
                for val in v[1:]:
                    print "      " + val


    def compare( self):
        """
        Check whether the two named files are equal.
        """
        self._src_1.parse()
        self._src_2.parse()

        if( self._src_1.all_records != self._src_2.all_records):
            self.emitDifferences( self._src_1.all_records, self._src_2.all_records)
            sys.exit("Differences detected")

if( len(sys.argv) != 3):
  sys.exit("Need two arguments")

verifier = LDIFVerifier( sys.argv[1], sys.argv[2])

verifier.compare()
