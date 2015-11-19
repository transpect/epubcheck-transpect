<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:opf="http://www.idpf.org/2007/opf"
  xmlns:ocf="urn:oasis:names:tc:opendocument:xmlns:container"
  exclude-result-prefixes="xs opf"
  version="2.0" 
  xpath-default-namespace="http://www.idpf.org/2007/opf">

  <xsl:param name="base-uri" as="xs:string" select="base-uri(/*)"/>

  <xsl:template match="/">
    <xsl:variable name="rootfile-paths" as="xs:string*"
      select="doc(resolve-uri('META-INF/container.xml', $base-uri))/ocf:container/ocf:rootfiles/ocf:rootfile/@full-path"/>
    <xsl:variable name="opf-paths" as="xs:string*" select="for $fp in $rootfile-paths 
                                                           return replace(replace($fp, '^(.+/)?.+$', '$1'), '/+', '/')"/>
    <cx:document name="wrap-file-uris">
      <xsl:apply-templates select="c:files/c:file[not(matches(@name, '^(mimetype$|META-INF/)'))]">
        <xsl:with-param name="opf-paths" as="xs:string*" select="$opf-paths[ends-with(., '/')]"/>
      </xsl:apply-templates>
    </cx:document>
  </xsl:template>
  
  <xsl:template match="c:file">
    <xsl:param name="opf-paths" as="xs:string*"/>
    <xsl:variable name="matching-opf-path" as="xs:string?" select="$opf-paths[starts-with(current()/@name, .)]"/>
    <xsl:variable name="slash-count" as="xs:integer" select="string-length(replace($matching-opf-path, '[^/]', ''))"/>
    <xsl:variable name="removed-opf-path" as="xs:string" 
      select="string-join(tokenize(@name, '/+')[position() gt $slash-count], '/')"/>
    <xsl:variable name="href" as="xs:string" select="string(resolve-uri(@name, $base-uri))"/>
    <c:file oebps-name="{@name}" href="{$href}" target-filename="{$href}" name="{$removed-opf-path}"/>
  </xsl:template>
  
</xsl:stylesheet>