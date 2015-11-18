<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:opf="http://www.idpf.org/2007/opf"
  exclude-result-prefixes="xs opf"
  version="2.0" 
  xpath-default-namespace="http://www.idpf.org/2007/opf">
  
  <xsl:template match="/">
    <cx:document name="wrap-data-uris">
      <xsl:apply-templates select="package/manifest/item"/>
    </cx:document>
  </xsl:template>
  
  <xsl:template match="item">
    <c:file oebps-name="{@href}" href="{resolve-uri(@href, base-uri(/*))}"/>
  </xsl:template>
  
</xsl:stylesheet>