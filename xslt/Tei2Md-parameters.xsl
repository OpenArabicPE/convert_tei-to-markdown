<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="2.0">
    <xsl:output method="text" encoding="UTF-8" indent="no" omit-xml-declaration="yes"/>
    <xsl:strip-space elements="*"/>
    
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>This stylesheet provides parameters for converting TEI XML to (multi)markdown</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:variable name="v_url-file" select="tei:TEI/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@type='url']"/>
    <xsl:variable name="v_new-line" select="'&#x0A;'"/>
    <xsl:param name="p_lang" select="'ar'"/>
    <xsl:param name="p_display-editorial-corrections" select="false()"/>
    <!-- toggle the YAML block at the beginning of each file -->
    <xsl:param name="p_include-yaml" select="false()"/>
    <xsl:variable name="v_include-yaml">
            <xsl:choose>
                <xsl:when test="$p_output-format = 'stylo'">
                    <xsl:value-of select="false()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$p_include-yaml"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
    <!-- values for $p_output-format are: md and stylo -->
    <xsl:param name="p_output-format" select="'stylo'"/>
    <xsl:param name="p_verbose" select="false()"/>
    <xsl:variable name="v_separator-attribute-key">
        <xsl:choose>
            <xsl:when test="$p_output-format = 'stylo'">
                <xsl:text>_</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>-</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="v_separator-attribute-value">
        <xsl:choose>
            <xsl:when test="$p_output-format = 'stylo'">
                <xsl:text>.</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>_</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
     <xsl:variable name="v_id-file">
          <xsl:variable name="v_id-file" select="if(tei:TEI/@xml:id) then(tei:TEI/@xml:id) else( tokenize(base-uri(),'/')[last()])"/>
         <xsl:choose>
             <xsl:when test="$p_output-format = 'stylo'">
                 <xsl:value-of select="translate($v_id-file,'_-','._')"/>
             </xsl:when>
             <xsl:otherwise>
                 <xsl:value-of select="$v_id-file"/>
             </xsl:otherwise>
         </xsl:choose>
     </xsl:variable>
</xsl:stylesheet>