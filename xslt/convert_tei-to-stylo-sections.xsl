<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:html="http://www.w3.org/1999/xhtml" 
    xmlns:oape="https://openarabicpe.github.io/ns"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc" xmlns="http://www.tei-c.org/ns/1.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs xd html" version="2.0">
    <xsl:output method="text" encoding="UTF-8" indent="yes" omit-xml-declaration="yes"/>
    <xsl:strip-space elements="*"/>

    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>This stylesheet produces a simple markdown file from TEI XML input</xd:p>
        </xd:desc>
    </xd:doc>

    <xsl:include href="Tei2Md-functions.xsl"/>
    
    <!-- variables -->
    <xsl:param name="p_minimal-section-length" select="3"/>

    <!-- save as new file -->
    <xsl:template match="/">
        <xsl:variable name="v_text-sections">
            <xsl:apply-templates select="descendant::tei:text/tei:body/tei:div[@type='section']"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$p_output-format = 'stylo'">
                <xsl:choose>
                <xsl:when test="number(count(tokenize(string($v_text-sections), '\W+'))) &gt;=$p_minimal-article-length">
                    <xsl:result-document href="../_output/{$v_file-name}">
                        <xsl:value-of select="$v_text-sections"/>
        </xsl:result-document>
                </xsl:when>
                    <xsl:otherwise>
                        <xsl:message>
                            <xsl:text>Sections are shorter than </xsl:text>
                            <xsl:value-of select="$p_minimal-article-length"/>
                            <xsl:text> words</xsl:text>
                        </xsl:message>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <!-- select only sections of minimal length -->
    <xsl:template match="tei:div[@type='section']">
        <!--<xsl:variable name="v_length" select="number(count(tokenize(string(.), '\W+')))"/>-->
        <xsl:choose>
            <xsl:when test="(count(tei:div) gt $p_minimal-section-length)">
                <xsl:apply-templates select="tei:head" mode="m_markdown"/>
                <xsl:apply-templates select="tei:div[@type='item']"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <!-- select only divs without author -->
    <xsl:template match="tei:div[@type='item']">
        <xsl:if test="oape:get-author-from-div(.) = 'NA'">
            <xsl:apply-templates select="." mode="m_markdown"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:variable name="v_file-name">
            <xsl:choose>
                <xsl:when test="$p_output-format = 'md'">
                    <xsl:value-of select="concat($v_file-name-base,'-sections.md')"/>
                </xsl:when>
                <xsl:when test="$p_output-format = 'stylo'">
                    <xsl:value-of select="concat('stylo/sections/w_',$p_minimal-article-length,'/')"/>
                    <!-- author, file, div -->
                    <xsl:value-of select="concat('oclc',$v_separator-attribute-value,$v_id-oclc,$v_separator-attribute-key,'v',$v_separator-attribute-value,translate($v_volume,'/','-'),$v_separator-attribute-key,'i',$v_separator-attribute-value, $v_issue,$v_separator-attribute-key,'sections.txt')"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>

    <!-- provide a YAML header -->
    <!--<xsl:template match="tei:teiHeader">
        <xsl:if test="$v_include-yaml = true()">
        <!-\- output -\->
<xsl:text>-\-\-</xsl:text><xsl:value-of select="$v_new-line"/>
<xsl:text>title: "</xsl:text><xsl:value-of select="$vPubTitle"/><xsl:text>"</xsl:text><xsl:value-of select="$v_new-line"/>
<xsl:text>author: </xsl:text><xsl:value-of select="$vAuthor"/><xsl:value-of select="$v_new-line"/>
<xsl:text>date: </xsl:text><xsl:value-of select="$vPubDate"/><xsl:value-of select="$v_new-line"/>
<xsl:text>-\-\-</xsl:text><xsl:value-of select="$v_new-line"/><xsl:value-of select="$v_new-line"/> 
        </xsl:if>
    </xsl:template>-->
</xsl:stylesheet>
