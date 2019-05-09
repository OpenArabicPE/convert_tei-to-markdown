<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:html="http://www.w3.org/1999/xhtml" 
    xmlns:oape="https://openarabicpe.github.io/ns"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc" xmlns="http://www.tei-c.org/ns/1.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs xd html" version="2.0">
    <xsl:output method="text" encoding="UTF-8" indent="no" omit-xml-declaration="yes"/>
    <xsl:strip-space elements="*"/>

    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>This stylesheet produces a simple markdown file from TEI XML input</xd:p>
        </xd:desc>
    </xd:doc>

    <xsl:include href="Tei2Md-functions.xsl"/>

    <!-- save as new file -->
    <xsl:template match="/">
        <xsl:result-document href="../_output/{$v_file-name}">
            <xsl:apply-templates select="descendant::tei:teiHeader"/>
            <xsl:apply-templates select="descendant::tei:text/tei:body" mode="mPlainText"/>
            <xsl:call-template name="t_notes"/>
        </xsl:result-document>
    </xsl:template>
    
    <!-- variables -->
     <xsl:variable name="vLang" select="'ar'"/>
        <xsl:variable name="vSourceBibl"
            select="ancestor::tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblStruct"/>
        <xsl:variable name="vPubTitle" select="$vSourceBibl/tei:monogr/tei:title[@xml:lang=$vLang][not(@type='sub')][1]"/>
<!--        <xsl:variable name="vAuthor1" select="$vSourceBibl/tei:monogr/tei:editor/tei:persName[@xml:lang=$vLang]"/>-->
        <xsl:variable name="vAuthor">
            <xsl:choose>
                <xsl:when test="$vSourceBibl/tei:monogr/tei:editor/tei:persName[@xml:lang=$vLang]/tei:surname">
                    <xsl:value-of select="$vSourceBibl/tei:monogr/tei:editor/tei:persName[@xml:lang=$vLang]/tei:surname"/>
                    <xsl:text>, </xsl:text>
                    <xsl:value-of select="$vSourceBibl/tei:monogr/tei:editor/tei:persName[@xml:lang=$vLang]/tei:forename"/>
                </xsl:when>
                <xsl:when test="$vSourceBibl/tei:monogr/tei:editor/tei:persName[@xml:lang=$vLang]">
                    <xsl:value-of select="$vSourceBibl/tei:monogr/tei:editor/tei:persName[@xml:lang=$vLang]"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="vPubDate" select="$vSourceBibl/tei:monogr/tei:imprint/tei:date[1]/@when"/>
    <xsl:variable name="v_file-name">
            <xsl:choose>
                <xsl:when test="$p_output-format = 'md'">
                    <xsl:value-of select="concat('md/',$v_id-file,'.md')"/>
                </xsl:when>
                <xsl:when test="$p_output-format = 'stylo'">
                    <!-- author, file, div -->
                    <xsl:value-of select="'stylo/'"/>
                    <xsl:choose>
                        <xsl:when test="$vAuthor/descendant-or-self::tei:persName/@ref">
                            <xsl:text>oape_</xsl:text>
                            <xsl:value-of select="oape:query-personography($vAuthor/descendant-or-self::tei:persName[1],$v_personography,'oape','')"/>
                        </xsl:when>
                        <xsl:when test="$vAuthor/descendant-or-self::tei:surname">
                            <xsl:value-of select="$vAuthor/descendant-or-self::tei:surname"/>
                        </xsl:when>
                        <xsl:when test="$vAuthor/descendant-or-self::tei:persName">
                            <xsl:value-of select="$vAuthor/descendant-or-self::tei:persName"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>NN</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:value-of select="concat('-',$v_id-file,'.txt')"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
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

    <!-- provide a YAML header -->
    <xsl:template match="tei:teiHeader">
        <xsl:if test="$v_include-yaml = true()">
        <!-- output -->
<xsl:text>---</xsl:text><xsl:value-of select="$v_new-line"/>
<xsl:text>title: "</xsl:text><xsl:value-of select="$vPubTitle"/><xsl:text>"</xsl:text><xsl:value-of select="$v_new-line"/>
<xsl:text>author: </xsl:text><xsl:value-of select="$vAuthor"/><xsl:value-of select="$v_new-line"/>
<xsl:text>date: </xsl:text><xsl:value-of select="$vPubDate"/><xsl:value-of select="$v_new-line"/>
<xsl:text>---</xsl:text><xsl:value-of select="$v_new-line"/><xsl:value-of select="$v_new-line"/> 
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>
