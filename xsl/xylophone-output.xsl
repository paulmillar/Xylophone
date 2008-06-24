<?xml version='1.0'?>

<!--+
    | Copyright (c) 2008, Paul Millar
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
    |  This file contains utility templates for emitting LDIF primitives,
    |  such as comments and attributes.
    +-->


<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version='1.0'>



<!--+
    |  Output a generic LDIF attribute.  This may wrap if it's too long.
    +-->
<xsl:template name="output-attribute">
  <xsl:param name="key"/>
  <xsl:param name="value" select="'UNDEFINEDVALUE'"/>

  <xsl:call-template name="output-line">
    <xsl:with-param name="text"><xsl:value-of select="$key"/>: <xsl:value-of select="$value"/></xsl:with-param>
  </xsl:call-template>
</xsl:template>




<!--+
    |  Output a comment line.  This may wrap if it's too long.
    +-->
<xsl:template name="output-comment">
  <xsl:param name="text"/>

  <xsl:call-template name="output-line">
    <xsl:with-param name="text">#  <xsl:value-of select="$text"/></xsl:with-param>
  </xsl:call-template>
</xsl:template>


<!--+
    |  Output a line of text, wrapping as necessary.
    +-->
<xsl:template name="output-line">
  <xsl:param name="text"/>

  <xsl:choose>
    <xsl:when test="string-length($text) > 75">
      <xsl:value-of select="substring($text,1,75)"/>
      <xsl:call-template name="output-EOL"/>

      <xsl:call-template name="output-partial-line">
	<xsl:with-param name="text" select="substring($text,76)"/>
      </xsl:call-template>
    </xsl:when>

    <xsl:otherwise>
      <xsl:value-of select="$text"/>
      <xsl:call-template name="output-EOL"/>
    </xsl:otherwise>
  </xsl:choose>

</xsl:template>


<xsl:template name="output-partial-line">
  <xsl:param name="text"/>

  <xsl:text> </xsl:text>

  <xsl:choose>
    <xsl:when test="string-length($text) > 74">
      <xsl:value-of select="substring($text,1,74)"/>
      <xsl:call-template name="output-EOL"/>

      <xsl:call-template name="output-partial-line">
	<xsl:with-param name="text" select="substring($text,75)"/>
      </xsl:call-template>
    </xsl:when>

    <xsl:otherwise>
      <xsl:value-of select="$text"/>
      <xsl:call-template name="output-EOL"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<xsl:template name="output-EOL">
  <xsl:text>&#xA;</xsl:text>
</xsl:template>

</xsl:stylesheet>
