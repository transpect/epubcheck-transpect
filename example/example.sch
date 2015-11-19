<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
  
  <ns prefix="c" uri="http://www.w3.org/ns/xproc-step"/>
  <ns prefix="cx" uri="http://www.w3.org/1999/xhtml"/>
  <ns prefix="html" uri="http://www.w3.org/1999/xhtml"/>
  <ns prefix="css" uri="http://www.w3.org/1996/css"/>
  
  <pattern id="kindle">
    <rule context="/c:wrap/cx:document">
      <assert test="true()">
        
      </assert>
    </rule>
  </pattern>
  
</schema>