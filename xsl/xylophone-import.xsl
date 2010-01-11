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
    |  Evaluate a lookup element.  The path to the current path is used to set the context
    |  for the lookup.  This allows relative XPaths to be processed correctly.
    +-->
<xsl:template name="eval-path">
  <!-- $current-path must be absolute -->
  <xsl:param name="current-path" select="'/'"/>
  <xsl:param name="lookup-path" select="'.'"/>
  <xsl:param name="default-value"/>

  <!-- We allow the XML src to be overwritten with the xml-src attribute -->
  <xsl:variable name="src">
    <xsl:choose>
      <xsl:when test="@xml-src">
       <xsl:value-of select="/xylophone/locations/location[@name=current()/@xml-src]"/>
      </xsl:when>
      <xsl:otherwise>
      <xsl:value-of select="$xml-src-uri"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="full-context-path">
    <xsl:choose>
      <xsl:when test="$current-path = '/'">
        <xsl:value-of select="concat(&quot;document('&quot;,$src,&quot;')&quot;)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat(&quot;document('&quot;,$src,&quot;')&quot;,$current-path)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <!-- Emit the expansion from the given XPath -->
  <xsl:choose>
    <!-- Try with EXSLT (xsltproc, xalan) -->
    <xsl:when test="function-available('dyn:evaluate')">
      <xsl:apply-templates select="dyn:evaluate($full-context-path)" mode="eval-path">
        <xsl:with-param name="lookup-path" select="$lookup-path"/>
        <xsl:with-param name="default-value" select="$default-value"/>
      </xsl:apply-templates>
    </xsl:when>

    <!-- Try with Saxon 6.5.5 -->
    <xsl:when test="function-available('saxon655:evaluate')">
      <xsl:apply-templates select="saxon655:evaluate($full-context-path)" mode="eval-path">
        <xsl:with-param name="lookup-path" select="$lookup-path"/>
        <xsl:with-param name="default-value" select="$default-value"/>
      </xsl:apply-templates>
    </xsl:when>

    <!-- Try with Saxon v9 -->
    <xsl:when test="function-available('saxon9:evaluate')">
      <xsl:apply-templates select="saxon9:evaluate($full-context-path)" mode="eval-path">
        <xsl:with-param name="lookup-path" select="$lookup-path"/>
        <xsl:with-param name="default-value" select="$default-value"/>
      </xsl:apply-templates>
    </xsl:when>

    <xsl:otherwise>
      <!-- We've already flagged this problem, just emit nothing -->
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>



<!-- Now we have the right context, expand the lookup-path -->
<xsl:template match="/|node()|@*" mode="eval-path">
  <xsl:param name="lookup-path" select="'.'"/>
  <xsl:param name="default-value"/>

  <!-- Does the lookup path exist? -->
  <xsl:variable name="valid-path">
    <xsl:choose>

      <!-- Try with EXSLT (xsltproc, xalan) -->
      <xsl:when test="function-available('dyn:evaluate')">
        <xsl:value-of select="boolean(dyn:evaluate($lookup-path))"/>
      </xsl:when>

      <!-- Try with Saxon 6.5.5 -->
      <xsl:when test="function-available('saxon655:evaluate')">
        <xsl:value-of select="boolean(saxon655:evaluate($lookup-path))"/>
      </xsl:when>

      <!-- Try with Saxon v9 -->
      <xsl:when test="function-available('saxon9:evaluate')">
        <xsl:value-of select="boolean(saxon9:evaluate($lookup-path))"/>
      </xsl:when>

      <xsl:otherwise>
        <!-- We've already flagged this as a problem -->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <!-- Emit the output -->
  <xsl:choose>
    <xsl:when test="$valid-path = 'true'">

      <!-- Emit the expansion from the given XPath -->
      <xsl:choose>
        <!-- Try with EXSLT (xsltproc, xalan) -->
        <xsl:when test="function-available('dyn:evaluate')">
          <xsl:value-of select="dyn:evaluate($lookup-path)"/>
        </xsl:when>

        <!-- Try with Saxon 6.5.5 -->
        <xsl:when test="function-available('saxon655:evaluate')">
          <xsl:value-of select="saxon655:evaluate($lookup-path)"/>
        </xsl:when>

        <!-- Try with Saxon v9 -->
        <xsl:when test="function-available('saxon9:evaluate')">
          <xsl:value-of select="saxon9:evaluate($lookup-path)"/>
        </xsl:when>

        <xsl:otherwise>
          <!-- We've already flagged this problem, just emit nothing -->
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>

    <xsl:otherwise>
      <xsl:value-of select="$default-value"/>
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

  <!-- We allow the XML src to be overwritten with the xml-src-uri attribute -->
  <xsl:variable name="src">
   <xsl:choose>
      <xsl:when test="@xml-src">
        <xsl:value-of select="/xylophone/locations/location[@name=current()/@xml-src]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$xml-src-uri"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <!-- Calculate the absolute path -->
  <xsl:variable name="abs-path">
    <xsl:call-template name="combine-paths">
      <xsl:with-param name="path" select="$path"/>
      <xsl:with-param name="rel-path" select="$rel-path"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="full-path" select="concat('document($src)/',$abs-path)"/>

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


<!--+
    |
    |  Path-based sum
    |
    |  Support for calculating the sum of elements selecting by specifying an XPath.
    |
    +-->
<xsl:template name="sum-path">
  <xsl:param name="rel-path"/>

  <!-- We allow the XML src to be overwritten with the xml-src-uri attribute -->
  <xsl:variable name="src">
    <xsl:choose>
      <xsl:when test="@xml-src">
        <xsl:value-of select="/xylophone/locations/location[@name=current()/@xml-src]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$xml-src-uri"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <!-- Calculate the absolute path -->
  <xsl:variable name="abs-path">
    <xsl:call-template name="combine-paths">
      <xsl:with-param name="path" select="@path"/>
      <xsl:with-param name="rel-path" select="$rel-path"/>
    </xsl:call-template>
  </xsl:variable>

  <!-- Full path includes the external document reference -->
  <xsl:variable name="full-path" select="concat('document($src)',$abs-path)"/>

  <xsl:choose>
    <!-- Support for Saxon 6.5.5 -->
    <xsl:when test="function-available('saxon655:evaluate')">
      <xsl:value-of select="sum(saxon655:evaluate($full-path))"/>
    </xsl:when>

    <!-- Support for Saxon v9 -->
    <xsl:when test="function-available('saxon9:evaluate')">
      <xsl:value-of select="sum(saxon9:evaluate($full-path))"/>
    </xsl:when>

    <!-- Support for EXSLT-supporting processors (e.g., xsltproc, xalan) -->
    <xsl:when test="function-available('dyn:evaluate')">
      <xsl:value-of select="sum(dyn:evaluate($full-path))"/>
    </xsl:when>

    <!-- Flag this as a problem -->
    <xsl:otherwise>
      <xsl:message>You are using an XSLT processor without evaluate() support.</xsl:message>
    </xsl:otherwise>
  </xsl:choose>

</xsl:template>


</xsl:stylesheet>
