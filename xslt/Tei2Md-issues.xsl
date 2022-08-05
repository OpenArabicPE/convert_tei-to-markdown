<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="xs xd html" version="3.0" xmlns="http://www.tei-c.org/ns/1.0" xmlns:html="http://www.w3.org/1999/xhtml" xmlns:oape="https://openarabicpe.github.io/ns"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xd="http://www.pnp-software.com/XSLTdoc" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0">
    <xsl:output encoding="UTF-8" indent="no" method="text" name="plain-text" omit-xml-declaration="yes"/>
    <xsl:strip-space elements="*"/>
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>This stylesheet produces a simple markdown file from TEI XML input</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:include href="functions.xsl"/>
    <!-- save as new file -->
    <xsl:template match="/">
        <xsl:result-document format="plain-text" href="../_output/{$v_file-name}">
            <xsl:apply-templates select="descendant::tei:teiHeader"/>
            <xsl:apply-templates mode="m_markdown" select="descendant::tei:text/tei:body"/>
            <xsl:call-template name="t_notes"/>
        </xsl:result-document>
    </xsl:template>
    <xsl:variable name="v_file-name">
        <!-- <xsl:message terminate="no">
            <xsl:text>OCLC = </xsl:text>
            <xsl:copy-of select="$v_id-oclc"/>
        </xsl:message>-->
        <xsl:choose>
            <xsl:when test="$p_output-format = 'md'">
                <xsl:value-of select="concat($v_file-name-base, '.md')"/>
            </xsl:when>
            <xsl:when test="$v_id-oclc = ''">
                <xsl:value-of select="concat($v_file-name_input, '.txt')"/>
            </xsl:when>
            <xsl:when test="$p_output-format = 'stylo'">
                <!--<xsl:value-of select="'stylo/issues/'"/>
                        <xsl:value-of
                            select="concat('oclc', $v_separator-attribute-value, $v_id-oclc, $v_separator-attribute-key, 'v', $v_separator-attribute-value, translate($v_volume, '/', '-'), $v_separator-attribute-key, 'i', $v_separator-attribute-value, $v_issue, '.txt')"
                        />-->
                <xsl:value-of select="concat($v_file-name_input, '.txt')"/>
            </xsl:when>
        </xsl:choose>
    </xsl:variable>
    <!-- provide a YAML header -->
    <xsl:template match="tei:teiHeader">
        <xsl:if test="$v_include-yaml = true()">
            <!-- output -->
            <xsl:text>---</xsl:text>
            <xsl:value-of select="$v_new-line"/>
            <!-- problem: we currently have no functions to generate YAML for a full issue, do we? -->
            <xsl:text>---</xsl:text>
            <xsl:value-of select="$v_new-line"/>
            <xsl:value-of select="$v_new-line"/>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>
