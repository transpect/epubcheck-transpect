<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  exclude-result-prefixes="#all"
  version="2.0">
  
  <xsl:param name="severity-default-name"/>
  
  <xsl:template match="/c:param-set">
    <epub-config>
      <checks>
        <xsl:apply-templates/>
      </checks>
    </epub-config>
  </xsl:template>
  
  <xsl:template match="c:param">
    <check value="{@value}">
      <xsl:analyze-string select="@name" regex="^(.+?)(_(error|fatal-error|info|warning))?$">
        <xsl:matching-substring>
          <xsl:attribute name="param" select="regex-group(1)"/>
          <xsl:attribute name="severity" select="(regex-group(3), $severity-default-name)[1]"/>
        </xsl:matching-substring>
      </xsl:analyze-string>  
    </check>
  </xsl:template>
  
</xsl:stylesheet>