<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="2.0">
    <xsl:output method="text" encoding="UTF-8" indent="no" omit-xml-declaration="yes"/>
    <xsl:strip-space elements="*"/>
    
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>This stylesheet provides functions/templates for converting TEI XML to (multi)markdown</xd:p>
        </xd:desc>
    </xd:doc>

    <xsl:include href="Tei2Md-parameters.xsl"/>
    
    <!-- heads -->
    
    <xsl:template match="tei:head">
        <!-- establish the level of nesting -->
        <xsl:variable name="v_level" select="number(count(ancestor::tei:div))"/>
        <xsl:value-of select="$vN"/>
        <xsl:value-of select="$vN"/>
        <xsl:choose>
            <xsl:when test="$v_level =1">
                <xsl:text># </xsl:text>
            </xsl:when>
            <xsl:when test="$v_level =2">
                <xsl:text>## </xsl:text>
            </xsl:when>
            <xsl:when test="$v_level =3">
                <xsl:text>### </xsl:text>
            </xsl:when>
            <xsl:when test="$v_level =4">
                <xsl:text>#### </xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text></xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:value-of select="."/><xsl:value-of select="$vN"/>
        <xsl:value-of select="$vN"/>
    </xsl:template>
    
    <!-- paragraphs, lines -->
    <xsl:template match="tei:p | tei:l" mode="mPlainText">
        <xsl:value-of select="$vN"/>
        <xsl:apply-templates mode="mPlainText"/>
        <xsl:value-of select="$vN"/>
    </xsl:template>
    
    <!-- page breaks, line breaks etc. -->
    <xsl:template match="tei:lb | tei:cb | tei:pb" mode="mPlainText">
        <xsl:text> </xsl:text>
    </xsl:template>
    
    <!-- segments of a line -->
    <xsl:template match="tei:l[@type='bayt']/tei:seg" mode="mPlainText">
        <xsl:apply-templates mode="mPlainText"/>
        <xsl:text> </xsl:text>
    </xsl:template>
    
    <!-- tables -->
    <xsl:template match="tei:table" mode="mPlainText">
        <xsl:value-of select="$vN"/>
        <xsl:apply-templates mode="mPlainText"/>
        <xsl:value-of select="$vN"/>
    </xsl:template>
    <xsl:template match="tei:row[@role='label']">
        <xsl:value-of select="$vN"/>
        <xsl:for-each select="tei:cell">
            <xsl:apply-templates mode="mPlainText"/><xsl:if test="position()!=last()"><xsl:text> | </xsl:text></xsl:if>
        </xsl:for-each>
        <xsl:value-of select="$vN"/>
        <xsl:for-each select="tei:cell">
            <xsl:text>-</xsl:text><xsl:if test="position()!=last()"><xsl:text>|</xsl:text></xsl:if>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="tei:row[@role='data']">
        <xsl:value-of select="$vN"/>
        <xsl:for-each select="tei:cell">
            <xsl:apply-templates mode="mPlainText"/><xsl:if test="position()!=last()"><xsl:text> | </xsl:text></xsl:if>
        </xsl:for-each>
    </xsl:template>

    <!-- plain text -->
    <xsl:template match="text()" mode="mPlainText">
        <!--<xsl:text> </xsl:text>--><xsl:value-of select="normalize-space(.)"/><!--<xsl:text> </xsl:text>-->
    </xsl:template>

    <!-- prevent notes in div/head from producing output -->
    <xsl:template match="tei:head/tei:note" mode="mPlainText"/>
    <!-- prevent output from sections of articles -->
    <xsl:template match="tei:div[@type = 'section'][ancestor::tei:div[@type = 'article']]"/>


</xsl:stylesheet>
