<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:c="http://www.w3.org/ns/xproc-step" 
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns:css="http://www.w3.org/1996/css"
  xmlns="http://www.w3.org/1999/xhtml"
  version="2.0" 
  exclude-result-prefixes="#all" 
  xpath-default-namespace="http://www.w3.org/1999/xhtml">
  
  <xsl:template match="@css:*"/>
  
  <xsl:template match="/">
    <html>
      <xsl:copy-of select="/c:wrap/cx:document[@name eq 'wrap-chunks']/html[1]/@*"/>
      <head>
        <xsl:copy-of select="/c:wrap/cx:document[@name eq 'wrap-chunks']/html[1]/head/*" copy-namespaces="no"/>
        <link rel="stylesheet" type="text/css" href="http://transpect.io/epubcheck-transpect/css/stylesheet.css"/>
      </head>
      <body>
        <xsl:apply-templates select="/c:wrap/cx:document[@name eq 'wrap-chunks']/html/body"/>  
      </body>
    </html>
  </xsl:template>
  
  <xsl:template match="body">
    <section class="epubcheck body">
      <xsl:attribute name="id" select="html:basename(parent::html/@xml:base)"/>
      <xsl:copy-of select="parent::html/@xml:base"/>
      <xsl:apply-templates select="@* except (@xml:base, @id)"/>
      <h4 class="epubcheck filename"><xsl:value-of select="replace(parent::html/@xml:base, '^.+/(.+)$', '$1')"/></h4>
      <xsl:apply-templates/>
    </section>
  </xsl:template>
  
  <!-- finally, there is only one html document, so we must fix the hyper references -->
  
  <xsl:template match="/c:wrap/cx:document[@name eq 'wrap-chunks']/html/body//a[@href][not(matches(@href, '^(https?:|mailto:)'))]" priority="10">
    <xsl:copy copy-namespaces="no">
      <xsl:variable name="href" select="@href" as="attribute(href)"/>
      <xsl:variable name="href-uri" 
        select="if(matches($href, '\.x?html', 'i'))
                then (/c:wrap/cx:document[@name eq 'wrap-chunks']//html[matches(@xml:base, replace($href, '#.+$', ''))][1]/@xml:base, base-uri())[1]
                else base-uri()" as="xs:anyURI"/>
      <xsl:attribute name="href" select="html:patch-href(@href, $href-uri)"/>
      <xsl:if test="@id">
        <xsl:attribute name="id" select="html:patch-id(@id, base-uri())"/>
      </xsl:if>
      <xsl:apply-templates select="@* except (@href, @id), node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="/c:wrap/cx:document[@name eq 'wrap-chunks']/html/body//*[@id]">
    <xsl:copy copy-namespaces="no">
      <xsl:attribute name="id" select="html:patch-id(@id, base-uri())"/>
      <xsl:apply-templates select="@* except @id, node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="@*|*">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*, node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:function name="html:patch-href" as="xs:string">
    <xsl:param name="href" as="xs:string"/>
    <xsl:param name="base-uri" as="xs:anyURI"/>
    <xsl:variable name="basename" select="html:basename($base-uri)" as="xs:string"/>
    <xsl:value-of select="if(matches($href, '\.x?html$', 'i'))
                            then concat('#', $basename)
                          else if(matches($href, '^#', 'i'))
                            then concat('#', $basename, '-', replace($href, '^#(.+)$', '$1'))
                          else concat('#', $basename, '-', replace($href, '^(.+\.x?html)#(.+)$', '$2'))"/>
  </xsl:function>
  
  <xsl:function name="html:patch-id" as="xs:string">
    <xsl:param name="id" as="xs:string"/>
    <xsl:param name="base-uri" as="xs:anyURI"/>
    <xsl:variable name="basename" select="html:basename($base-uri)"/>
    <xsl:value-of select="concat($basename, '-', $id)"/>
  </xsl:function>
  
  <xsl:function name="html:basename" as="xs:string">
    <xsl:param name="base-uri" as="xs:anyURI"/>
    <xsl:value-of select="replace($base-uri, '^.+/(.+)\.x?html$', '$1', 'i')"/>
  </xsl:function>
  
</xsl:stylesheet>