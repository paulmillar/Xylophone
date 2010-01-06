#!/usr/bin/python

import sys
from ldif import LDIFParser, LDIFWriter, LDIFRecordList

class LDIFVerifier():
    """
    Check that two LDIF files contain equivalent LDAP information.  If they
    don't, emit a summary of the differences
    """

    def __init__( self, file1, file2):
        """
        Parameters:
        file1
            filename of first file to read
        file2
            filename of second file to read
        """
        self.src1 = LDIFRecordList(open(file1))
        self.src2 = LDIFRecordList(open(file2))


    def emitDifferingValues( self, attributes1, attributes2):
        """
        Emit a description of the differences between two dictionaries of attribute values
        """
        for attributeName, attributeValues1 in attributes1.iteritems():
            if attributeName in attributes2:
                attributeValues2 = attributes2[attributeName]
                if attributeValues1 != attributeValues2:
                    print "        " + attributeName + ": " + str(attributeValues1) + " != " + str(attributeValues2)
            else:
                print "        " + attributeName + ": missing in second file"

    def emitDifferences( self, summary1, summary2):
        """
        Emit all differences between the two LDAP objects.  The
        supplied parameters are dictionaries between the object DN and
        a list of attributes
        """
        count = 0
        for dnLower,wrappedObject1 in summary1.iteritems():
            (dn,attributes1) = wrappedObject1
            if dnLower in summary2:
                wrappedObject2 = summary2 [dnLower]
                (dn2,attributes2) = wrappedObject2
                if( attributes1 != attributes2):
                    count += 1
                    print "\n    dn: " + dn
                    print "        [difference in attribute values]\n"
                    self.emitDifferingValues( attributes1, attributes2)
            else:
                count += 1
                print "\n    dn: " + dn
                print "        [object missing in second file]\n"
                self.printSummary( dn, attributes1)

        for dnLower,wrappedObject2 in summary2.iteritems():
            (dn,attributes2) = wrappedObject2
            if not dnLower in summary1:
                count += 1
                print "\n    dn: " + dn
                print "        [object missing in first file]\n"
                self.printSummary( dn, attributes2)
        return count


    def printSummary( self, dn, attributes):
        """
        Print a complete LDAP object
        """
        for attributeName, attributeValues in attributes.iteritems():
            for attributeValue in attributeValues:
                print "        " + attributeName + ": " + attributeValue

    def buildSummary( self, records):
        """
        Build 
        """
        summary = {}

        for record in records:
            dn,attributes = record
            summary [dn.lower()] = (dn,attributes)

        return summary


    def compare( self):
        """
        Check whether the two named files are equal.
        """
        self.src1.parse()

        summary1 = self.buildSummary( self.src1.all_records)

        self.src2.parse()

        summary2 = self.buildSummary( self.src2.all_records)

        count = self.emitDifferences( summary1, summary2)
        if( count > 0):
            exit(1)

if( len(sys.argv) != 3):
  sys.exit("Need two arguments")

verifier = LDIFVerifier( sys.argv[1], sys.argv[2])

verifier.compare()
