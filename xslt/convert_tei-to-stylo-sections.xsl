<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="xs xd html" version="2.0"
    xmlns="http://www.tei-c.org/ns/1.0" xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:oape="https://openarabicpe.github.io/ns" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0">
    <xsl:output encoding="UTF-8" indent="yes" method="text" omit-xml-declaration="yes"/>
    <xsl:strip-space elements="*"/>
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>This stylesheet produces a plain text file for each div[@type = 'section'] in the body of a TEI XML input</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:include href="functions.xsl"/>
    <!-- variables -->
    <xsl:param name="p_minimal-section-length" select="3"/>
    <xsl:variable name="v_file-name">
        <xsl:choose>
            <xsl:when test="$p_output-format = 'md'">
                <xsl:value-of select="concat($v_file-name-base, '-sections.md')"/>
            </xsl:when>
            <xsl:when test="$p_output-format = 'stylo'">
                <xsl:value-of select="concat('stylo/sections/w_', $p_minimal-article-length, '/')"/>
                <!-- author, file, div -->
                <xsl:value-of
                    select="concat('oclc', $v_separator-attribute-value, $v_id-oclc, $v_separator-attribute-key, 'v', $v_separator-attribute-value, translate($v_volume, '/', '-'), $v_separator-attribute-key, 'i', $v_separator-attribute-value, $v_issue, $v_separator-attribute-key, 'sections.txt')"
                />
            </xsl:when>
        </xsl:choose>
    </xsl:variable>
    
    <!-- save as new file -->
    <xsl:template match="/">
        <xsl:variable name="v_text-sections">
            <xsl:apply-templates select="descendant::tei:text/tei:body/tei:div[@type = 'section']" mode="m_stylo"/>
        </xsl:variable>
        <xsl:variable name="v_length" select="number(count(tokenize(string($v_text-sections), '\W+')))"/>
        <xsl:if test="$p_debug = true()">
            <xsl:message>
                <xsl:text>Sections in this file are </xsl:text>
                <xsl:value-of select="$v_length"/>
                <xsl:text> words long.</xsl:text>
            </xsl:message>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="$p_output-format = 'stylo'">
                <xsl:choose>
                    <xsl:when
                        test="$v_length &gt;= $p_minimal-article-length">
                        <xsl:result-document href="../_output/{$v_file-name}">
                            <xsl:copy-of select="$v_text-sections"/>
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
    <xsl:template match="tei:div[@type = 'section']" mode="m_stylo">
        <xsl:variable name="v_item-count" select="count(tei:div[@type = 'item'])"/>
        <xsl:if test="$p_debug = true()">
                <xsl:message>
                    <xsl:text>Found a section with </xsl:text>
                    <xsl:value-of select="$v_item-count"/>
                    <xsl:text> items.</xsl:text>
                </xsl:message>
            </xsl:if>
        <xsl:choose>
            <xsl:when test="$v_item-count &gt;= $p_minimal-section-length">
                <xsl:apply-templates mode="m_markdown" select="tei:head"/>
                <xsl:apply-templates select="tei:div[@type = 'item']" mode="m_stylo"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <!-- select only divs without author -->
    <xsl:template match="tei:div[@type = 'item']" mode="m_stylo">
        <xsl:if test="oape:get-author-from-div(.) = 'NA'">
            <xsl:if test="$p_debug = true()">
                <xsl:message>Found anonymous item.</xsl:message>
            </xsl:if>
            <xsl:apply-templates mode="m_markdown" select="."/>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>
