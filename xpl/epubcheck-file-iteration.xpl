<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" 
  xmlns:cx="http://xmlcalabash.com/ns/extensions" 
  xmlns:tr="http://transpect.io"
  xmlns:epubcheck="http://transpect.io/epubcheck"
  version="1.0"
  name="file-iteration"
  type="epubcheck:file-iteration">
  
  <p:input port="source" primary="true"/>
  <p:input port="params" primary="false"/>
  
  <p:output port="result"/>
  
  <p:option name="file" required="true"/>
  <p:option name="debug" select="'yes'"/>
  <p:option name="debug-dir-uri" select="'debug'"/>  
  <p:option name="status-dir-uri" select="concat($debug-dir-uri, '/status')"/>
  
  <p:import href="http://transpect.io/calabash-extensions/unzip-extension/unzip-declaration.xpl"/>
  <p:import href="http://transpect.io/xproc-util/file-uri/xpl/file-uri.xpl"/>
  <p:import href="http://transpect.io/xproc-util/load/xpl/load.xpl"/>
  <p:import href="http://transpect.io/xproc-util/simple-progress-msg/xpl/simple-progress-msg.xpl"/>
  <p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl"/>
  
  <p:try>
    <p:group>
      <p:variable name="dest-dir" select="concat(replace($file, '^(.+)/.+$', '$1/'), 'archive')"/>
      
      <tr:simple-progress-msg file="epubcheck-transpect_extract.txt">
        <p:input port="msgs">
          <p:inline>
            <c:messages>
              <c:message xml:lang="en">Dekomprimiere Archiv</c:message>
              <c:message xml:lang="de">Extract archive</c:message>
            </c:messages>
          </p:inline>
        </p:input>
        <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
      </tr:simple-progress-msg>
      
      <cx:message>
        <p:with-option name="message" select="'[info] unzip: ', $file, ' &#xa; => ', $dest-dir"/>
      </cx:message>
      
      <tr:unzip name="unzip">
        <p:with-option name="zip" select="$file"/>
        <p:with-option name="dest-dir" select="$dest-dir"/>
        <p:with-option name="overwrite" select="'yes'"/>
      </tr:unzip>
      
      <tr:store-debug pipeline-step="epubcheck-transpect/archive">
        <p:with-option name="active" select="$debug"/>
        <p:with-option name="base-uri" select="$debug-dir-uri"/>
      </tr:store-debug>
      
      <p:group>
        <p:variable name="base-uri" select="/c:files/@xml:base"/>
        <p:variable name="container-xml" select="/c:files/c:file[@name eq 'META-INF/container.xml']/@name"/>
        
        <!-- load META-INF/container.xml to retrieve the path of the OPF file -->
        
        <cx:message>
          <p:with-option name="message" select="'[info] load Container-XML: ', $container-xml"/>
        </cx:message>
        
        <tr:load fail-on-error="true" name="load-container-xml">
          <p:with-option name="href" select="replace(concat($base-uri, $container-xml), '%2F', '/')"/>
        </tr:load>
        
        <tr:store-debug pipeline-step="epubcheck-transpect/archive_container-xml">
          <p:with-option name="active" select="$debug"/>
          <p:with-option name="base-uri" select="$debug-dir-uri"/>
        </tr:store-debug>
        
        <!-- load OPF file -->
        
        <cx:message>
          <p:with-option name="message" select="'[info] load OPF: ', /*:container/*:rootfiles[1]/*:rootfile[1]/@full-path"/>
        </cx:message>
        
        <tr:load fail-on-error="true" name="load-opf">
          <p:with-option name="href" select="replace(concat($base-uri, /*:container/*:rootfiles[1]/*:rootfile[1]/@full-path), '%2F', '/')"/>
        </tr:load>
        
        <tr:store-debug pipeline-step="epubcheck-transpect/archive_opf">
          <p:with-option name="active" select="$debug"/>
          <p:with-option name="base-uri" select="$debug-dir-uri"/>
        </tr:store-debug>
                
        <p:group>
          <p:variable name="opf-href" select="/*/@xml:base">
            <p:pipe port="result" step="load-opf"/>
          </p:variable>
            
          <!-- load NCX file if exists -->
            
          <cx:message>
            <p:with-option name="message" select="'[info] load NCX if exists: ', /*:package/*:manifest/*:item[@media-type eq 'application/x-dtbncx+xml']/@full-path"/>
          </cx:message>
          
          <tr:load fail-on-error="false" name="load-ncx">
            <p:with-option name="href" select="replace(concat($base-uri, /*:package/*:manifest/*:item[@media-type eq 'application/x-dtbncx+xml']/@href), '%2F', '/')"/>
          </tr:load>
          
          <tr:store-debug pipeline-step="epubcheck-transpect/archive_ncx">
            <p:with-option name="active" select="$debug"/>
            <p:with-option name="base-uri" select="$debug-dir-uri"/>
          </tr:store-debug>
        
          <p:for-each name="content-file-iteration">
            <p:iteration-source select="/*:package/*:spine/*:itemref">
              <p:pipe port="result" step="load-opf"/>
            </p:iteration-source>
            <p:variable name="itemref-id" select="*:itemref/@idref"/>
            <p:variable name="content-href" select="replace(concat(replace($opf-href, '^(.+/).+$', '$1'), /*:package/*:manifest/*:item[@id eq $itemref-id]/@href), '%2F', '/')">
              <p:pipe port="result" step="load-opf"/>
            </p:variable>
            
            <cx:message>
              <p:with-option name="message" select="'[info] load content-file: ', $content-href"/>
            </cx:message>
            
            <tr:load fail-on-error="false" name="load-content-files">
              <p:with-option name="href" select="$content-href">
              </p:with-option>
            </tr:load>
            
          </p:for-each>
          
        </p:group>
      </p:group>
      
      <p:wrap-sequence wrapper="bla">
      </p:wrap-sequence>
      
      
      <!--<p:for-each name="file-iteration">
      <p:iteration-source select="//c:file[matches(@name, '\.(xml|pdf)$')][not(matches(@name, '/(suppl|graphic|media)/'))]"/>
      <p:variable name="base" select="/c:files/@xml:base">
        <p:pipe port="result" step="unzip"/>
      </p:variable>
      <p:variable name="href" select=" replace(concat($base, c:file/@name), '%2F', '/')"/>
      
      <p:choose>
        <p:when test="//c:file[matches(@name, '\.xml$')]">
        
          <cx:message>
            <p:with-option name="message" select="'[info] load file: ', c:file/@name"/>
          </cx:message>
          
          <tr:load>
            <p:with-option name="href" select="$href"/>
          </tr:load>                
          
        </p:when>
        <p:when test="//c:file[matches(@name, '\.pdf$')]">
          
          <cx:message>
            <p:with-option name="message" select="'[info] check pdf: ', c:file/@name"/>
          </cx:message>
          
          <sc:pdfinfo>
            <p:with-option name="file" select="$href"/>
            <p:with-option name="debug" select="$debug"/>
            <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
            <p:with-option name="status-dir-uri" select="$status-dir-uri"/>  
          </sc:pdfinfo>
          
        </p:when>
      </p:choose>
      
    </p:for-each>-->
      
      <!-- wrap elements -->
      
      <!--    <p:wrap-sequence wrapper="set" wrapper-prefix="sc" wrapper-namespace="http://degruyter.com/xmlns/submissionchecker"/>
    
    <p:wrap match="book|article|issue-xml" group-adjacent="local-name()" wrapper="content" wrapper-prefix="sc" wrapper-namespace="http://degruyter.com/xmlns/submissionchecker"/>
    
    <p:wrap match="c:pdf" group-adjacent="@type eq 'pdfinfo'" wrapper="pdfinfo" wrapper-prefix="sc" wrapper-namespace="http://degruyter.com/xmlns/submissionchecker"/>
-->    
      <!-- insert zip archive listing -->
      <!--    
    <p:insert match="/sc:set" position="last-child">
      <p:input port="insertion">
        <p:pipe port="source" step="sc-file-iteration"/>
      </p:input>
    </p:insert>
    
    <p:insert match="/sc:set" position="last-child">
      <p:input port="insertion">
        <p:pipe port="result" step="simple-sort-unzip"/>
      </p:input>
    </p:insert>
    
    <p:insert match="/sc:set" position="last-child">
      <p:input port="insertion">
        <p:pipe port="params" step="sc-file-iteration"/>
      </p:input>
    </p:insert>
    
    <p:wrap match="c:files" wrapper="files" wrapper-prefix="sc" wrapper-namespace="http://degruyter.com/xmlns/submissionchecker"/>
    <p:wrap match="c:param-set" wrapper="params" wrapper-prefix="sc" wrapper-namespace="http://degruyter.com/xmlns/submissionchecker"/>
    <p:wrap match="product_export" wrapper="meta" wrapper-prefix="sc" wrapper-namespace="http://degruyter.com/xmlns/submissionchecker"/>
    
    <p:add-attribute attribute-name="xml:base" match="sc:set">
      <p:with-option name="attribute-value" select="$zip"/>
    </p:add-attribute>
    
    <tr:store-debug pipeline-step="sc-file-iteration/set">
      <p:with-option name="active" select="$debug"/>
      <p:with-option name="base-uri" select="$debug-dir-uri"/>
    </tr:store-debug>
-->        
    </p:group>
    <p:catch name="catch">
      
      <p:identity>
        <p:input port="source">
          <p:pipe port="error" step="catch"/>
        </p:input>
      </p:identity>
      
    </p:catch>
  </p:try>
  
</p:declare-step>