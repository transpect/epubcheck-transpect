<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" 
  xmlns:tr="http://transpect.io"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  queryBinding="xslt2"
  tr:rule-family="business-rules">
  
  <!-- this schematron example file is applied on an XML representation 
       of the EPUB file. You can get this XML representation by executing 
       epubcheck-transpect with the -d option. The file is stored to 
       this location:
       {OUTPUT}{BASENAME.tmp}/debug/epubcheck-validate/wrap-with-srcpaths.xml
       
       When you write schematron rules, please not that you have to add a proper @id
       to your assert/report statements.
       
       In your assert/report you should insert this line to select where the error
       message is inserted:
       <span class="srcpath"><xsl:value-of select="@srcpath"/></span>
       
       Add an @role attribute to change the warning category (e.g. 'error', 'warning', 'info').
  -->
  
  <ns prefix="c" uri="http://www.w3.org/ns/xproc-step"/>
  <ns prefix="cx" uri="http://www.w3.org/1999/xhtml"/>
  <ns prefix="html" uri="http://www.w3.org/1999/xhtml"/>
  <ns prefix="css" uri="http://www.w3.org/1996/css"/>
  
  <pattern id="css-color">
    <rule context="html:*[@css:color]">
      <assert test="not(matches(@css:color, '^[a-z\-]+$', 'i'))" id="css-color-name" role="info">
        <span class="srcpath"><xsl:value-of select="@srcpath"/></span>
        You used a named CSS color value: <value-of select="@css:color"/>. You should use a hex color value (e.g. #ca32de) for better compatibility.
      </assert>
    </rule>
  </pattern>
  
  <pattern id="kindle">
    <rule context="html:*[@css:max-width]">
      <assert test="false()" id="kindle-max-width" role="warning">
        <span class="srcpath"><xsl:value-of select="@srcpath"/></span>
        You used CSS max-width. Unfortunately, this may not render clearly on all Kindle readers.
      </assert>
    </rule>
  </pattern>
  
</schema>