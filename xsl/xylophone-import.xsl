<?xml version="1.0" encoding="utf-8"?>

<!--+
    | Copyright (c) 2008, Deutsches Elektronen-Synchrotron (DESY)
    | All rights reserved.
    | 
    | Redistribution and use in source and binary forms, with
    | or without modification, are permitted provided that the
    | following conditions are met:
    | 
    |   o  Redistributions of source code must retain the above
    |      copyright notice, this list of conditions and the
    |      following disclaimer.
    | 
    |   o  Redistributions in binary form must reproduce the
    |      above copyright notice, this list of conditions and
    |      the following disclaimer in the documentation and/or
    |      other materials provided with the distribution.
    |
    |   o  Neither the name of Deutsches Elektronen-Synchrotron
    |      (DESY) nor the names of its contributors may be used
    |      to endorse or promote products derived from this
    |      software without specific prior written permission.
    |
    | THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND
    | CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
    | INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
    | MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
    | DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
    | CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
    | SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
    | NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
    | LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
    | HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
    | CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
    | OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
    | SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
    +-->

<!--+
    |
    |  This file contains support for importing data from external source
    |
    +-->

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:dyn="http://exslt.org/dynamic"
		xmlns:saxon655="http://icl.com/saxon"
		xmlns:saxon9="http://saxon.sf.net/"
                extension-element-prefixes="dyn saxon9 saxon655">

<!--+
    |  Lookup a value with given path from $xml-src-uri.  If the result would
    |  be empty then return default value.  If default isn't specified then
    |  nothing is emitted.
    +-->
<xsl:template name="eval-path">
  <xsl:param name="path"/>
  <xsl:param name="default"/>

  <xsl:variable name="full-path" select="concat(&quot;document('&quot;,$xml-src-uri,&quot;')/&quot;,$path)"/>

  <xsl:variable name="result">
    <xsl:choose>

      <!-- Try with Saxon 6.5.5 -->
      <xsl:when test="function-available('saxon655:evaluate')">
	<xsl:value-of select="saxon655:evaluate($full-path)"/>
      </xsl:when>

      <!-- Try with Saxon v9 -->
      <xsl:when test="function-available('saxon9:evaluate')">
	<xsl:value-of select="saxon9:evaluate($full-path)"/>
      </xsl:when>

      <!-- Try with EXSLT (xsltproc, xalan) -->
      <xsl:when test="function-available('dyn:evaluate')">
	<xsl:value-of select="dyn:evaluate($full-path)"/>
      </xsl:when>

      <!-- Flag this as a problem -->
      <xsl:otherwise>
	<xsl:message>You are using an XSLT processor without evaluate() support.</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="$result">
      <xsl:value-of select="$result"/>
    </xsl:when>

    <xsl:otherwise>
      <xsl:value-of select="$default"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<!--+
    |
    |  Count-path
    |
    |  Support for counting number of elements that match a certain
    |  path
    |
    +-->
<xsl:template name="count-path">
  <xsl:param name="path"/>
  <xsl:param name="rel-path"/>

  <!-- Calculate the absolute path -->
  <xsl:variable name="abs-path">
    <xsl:call-template name="combine-paths">
      <xsl:with-param name="path" select="$path"/>
      <xsl:with-param name="rel-path" select="$rel-path"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="full-path" select="concat('document($xml-src-uri)/',$abs-path)"/>

  <xsl:choose>
    <!-- Support for Saxon 6.5.5 -->
    <xsl:when test="function-available('saxon655:evaluate')">
      <xsl:value-of select="count(saxon655:evaluate($full-path))"/>
    </xsl:when>
    
    <!-- Support for Saxon v9 -->
    <xsl:when test="function-available('saxon9:evaluate')">
      <xsl:value-of select="count(saxon9:evaluate($full-path))"/>
    </xsl:when>

    <!-- Support for EXSLT-supporting processors (e.g., xsltproc, xalan) -->
    <xsl:when test="function-available('dyn:evaluate')">
      <xsl:value-of select="count(dyn:evaluate($full-path))"/>
    </xsl:when>

    <!-- Flag this as a problem -->
    <xsl:otherwise>
      <xsl:message>You are using an XSLT processor without evaluate() support.</xsl:message>
    </xsl:otherwise>
  </xsl:choose>

</xsl:template>


</xsl:stylesheet>
