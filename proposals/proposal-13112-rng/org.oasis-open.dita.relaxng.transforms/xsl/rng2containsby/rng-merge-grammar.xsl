<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:rng="http://relaxng.org/ns/structure/1.0"
  xmlns:rnga="http://relaxng.org/ns/compatibility/annotations/1.0"
  xmlns:rng2ditadtd="http://dita.org/rng2ditadtd"
  xmlns:relpath="http://dita2indesign/functions/relpath"
  xmlns:str="http://local/stringfunctions"
  xmlns:ditaarch="http://dita.oasis-open.org/architecture/2005/"
  xmlns:rngfunc="http://dita.oasis-open.org/dita/rngfunctions"
  exclude-result-prefixes="xs xd rnga relpath str ditaarch rngfunc"
  version="2.0">
  
  <xsl:template match="rng:grammar" mode="merge-grammar" priority="10">
    <xsl:document>
      <xsl:copy>
        <xsl:attribute name="datatypeLibrary" select="'http://www.w3.org/2001/XMLSchema-datatypes'"/>
        <xsl:apply-templates mode="#current" select="@*,*"/>
      </xsl:copy>
    </xsl:document>
  </xsl:template>
  
  <xsl:template mode="merge-grammar" match="rng:include">
    <xsl:variable name="doc" select="document(@href)" as="document-node()?"/>
    <xsl:choose>
      <xsl:when test="not($doc)">
        <xsl:message> + [ERROR] rng:include: Failed to resolve reference to @href value "<xsl:value-of select="@href"/>"</xsl:message>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="$doc/rng:grammar/*" mode="#current"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template mode="merge-grammar" match="rng:externalRef">
    <xsl:variable name="doc" select="document(@href)" as="document-node()?"/>
    <xsl:choose>
      <xsl:when test="not($doc)">
        <xsl:message> + [ERROR] rng:externalRef: Failed to resolve reference to @href value "<xsl:value-of select="@href"/>"</xsl:message>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="/rng:grammar/rng:start" mode="#current"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="text()" mode="merge-grammar">
    <xsl:sequence select="."/>
  </xsl:template>
  
  <xsl:template match="*" mode="merge-grammar">
    <xsl:copy>
      <xsl:apply-templates mode="#current" select="@*,node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="ditaarch:*" mode="merge-grammar">
    <xsl:element name="{local-name(.)}" namespace="http://dita.oasis-open.org/architecture/2005/">
      <xsl:apply-templates mode="#current" select="@*, node()"/>
    </xsl:element>
    
  </xsl:template>
  
  <xsl:template match="@*" mode="merge-grammar">
   <xsl:sequence select="."/>
  </xsl:template>
  
</xsl:stylesheet>