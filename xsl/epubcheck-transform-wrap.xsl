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
      </head>
      <body>
        <xsl:apply-templates select="/c:wrap/cx:document[@name eq 'wrap-chunks']/html/body"/>  
      </body>
    </html>
  </xsl:template>
  
  <xsl:template match="body">
    <section class="body">
      <xsl:copy-of select="parent::html/@xml:base"/>
      <xsl:apply-templates select="@* except @xml:base, node()"/>
    </section>
  </xsl:template>
  
  <xsl:template match="@*|*">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*, node()"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>