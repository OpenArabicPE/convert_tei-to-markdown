<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:html="http://www.w3.org/1999/xhtml" 
    xmlns:oape="https://openarabicpe.github.io/ns"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc" xmlns="http://www.tei-c.org/ns/1.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs xd html" version="3.0">
    <xsl:output method="text" encoding="UTF-8" indent="no" omit-xml-declaration="yes"/>
    <xsl:strip-space elements="*"/>

    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>This stylesheet produces a simple plain text file for each page in an TEI XML input</xd:p>
        </xd:desc>
    </xd:doc>

    <!--<xsl:include href="Tei2Md-functions.xsl"/>-->
    
    <!-- variables -->
    <xsl:param name="p_min-section-length" select="3"/>
    <xsl:param name="p_output-path" select="'_output/plain-text_pages/'"/>
    <xsl:variable name="v_new-line" select="'&#x0A;'"/>
    
    <xsl:template match="/">
        <xsl:apply-templates select="descendant::tei:pb[@ed='print']" mode="m_page-to-file"/>
    </xsl:template>
    
    <xsl:template match="tei:pb[@ed='print']" mode="m_page-to-file">
        <xsl:variable name="v_page-number" select="@n"/>
        <xsl:variable name="v_following-pb" select="following::tei:pb[@ed='print'][1]"/>
            <xsl:message>
                <xsl:value-of select="$v_page-number"/>
            </xsl:message>
        <xsl:result-document href="{concat($p_output-path,'p_',$v_page-number,'.txt')}">
                <xsl:apply-templates select="following::node()[. &lt;&lt; $v_following-pb]" mode="m_plain-text"/>
            </xsl:result-document>
    </xsl:template>
    <xsl:template match="text()" mode="m_plain-text" priority="10">
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>
    <xsl:template match="tei:lb[@ed='print'] | tei:p | tei:div | tei:head" mode="m_plain-text">
        <xsl:value-of select="$v_new-line"/>
    </xsl:template>
    <xsl:template match="node()" mode="m_plain-text"/>
    
</xsl:stylesheet>
