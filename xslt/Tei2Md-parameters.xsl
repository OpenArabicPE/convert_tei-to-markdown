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
    
    <xsl:variable name="v_id-file" select="tei:TEI/@xml:id"/>
    <xsl:variable name="v_url-file" select="tei:TEI/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@type='url']"/>
    <xsl:variable name="v_new-line" select="'&#x0A;'"/>
    <xsl:param name="p_lang" select="'ar'"/>
    <xsl:param name="p_display-editorial-corrections" select="false()"/>
    <!-- toggle the YAML block at the beginning of each file -->
    <xsl:param name="p_include-yaml" select="false()"/>
    <!-- values for $p_output-format are: md and stylo -->
    <xsl:param name="p_output-format" select="'stylo'"/>
    
</xsl:stylesheet>