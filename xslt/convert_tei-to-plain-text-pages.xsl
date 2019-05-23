<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="xs xd html" version="3.0" xmlns="http://www.tei-c.org/ns/1.0" xmlns:html="http://www.w3.org/1999/xhtml" xmlns:oape="https://openarabicpe.github.io/ns" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xd="http://www.pnp-software.com/XSLTdoc" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xpath-default-namespace="http://www.tei-c.org/ns/1.0">
    <xsl:output encoding="UTF-8" indent="no" method="text" omit-xml-declaration="yes"/>
    <xsl:strip-space elements="*"/>
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>This stylesheet produces a simple plain text file for each page in an TEI XML input</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:include href="Tei2Md-functions.xsl"/>
    <!-- variables -->
    <xsl:param name="p_min-section-length" select="3"/>
    <xsl:param name="p_output-path" select="'_output/plain-text_pages/'"/>
    <xsl:variable name="v_file-name" select="concat('oclc_',$v_id-oclc,'-v_', $v_volume, '-i_',$v_issue)"/>
   
    <xsl:template match="/">
        <xsl:apply-templates mode="m_page-to-file" select="descendant::tei:pb[@ed='print']"/>
    </xsl:template>
    <xsl:template match="tei:pb[@ed='print']" mode="m_page-to-file">
        <xsl:variable name="v_page-number" select="@n"/>
        <xsl:variable name="v_following-pb" select="following::tei:pb[@ed='print'][1]"/>
        <!--<xsl:message>
            <xsl:value-of select="$v_page-number"/>
        </xsl:message>-->
        <xsl:result-document href="{concat($p_output-path,$v_file-name,'-p_',format-number($v_page-number,'000'),'.txt')}">
            <xsl:choose>
                <!-- all but the final page -->
                <xsl:when test="following::tei:pb[@ed='print']">
                    <xsl:apply-templates mode="m_plain-text" select="following::node()[. &lt;&lt; $v_following-pb]"/>
                    <xsl:value-of select="$v_new-line"/>
                    <!-- add foot notes -->
                    <xsl:apply-templates mode="m_footnote" select="following::node()[. &lt;&lt; $v_following-pb]"/>
                </xsl:when>
                <!-- the final page -->
                <xsl:otherwise>
                    <xsl:variable name="v_final-node" select="following::node()[last()]"/>
                    <xsl:apply-templates mode="m_plain-text" select="following::node()[. &lt;&lt; $v_final-node]"/>
                    <xsl:value-of select="$v_new-line"/>
                    <!-- add foot notes -->
                    <xsl:apply-templates mode="m_footnote" select="following::node()[. &lt;&lt; $v_final-node]"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:result-document>
    </xsl:template>
    <!-- this is part of the external stylesheet -->
    <!--<xsl:template match="text()" mode="m_plain-text" priority="10">
        <xsl:value-of select="concat(' ',normalize-space(.),' ')"/>
    </xsl:template>-->
    <xsl:template match="tei:lb[@ed='print'] | tei:l | tei:p | tei:div | tei:head" mode="m_plain-text m_footnote-text">
        <xsl:value-of select="$v_new-line"/>
    </xsl:template>
    <xsl:template match="node()" mode="m_plain-text m_footnote"/>
    <!-- deal with notes -->
    <xsl:template match="tei:note[@place = 'bottom']" mode="m_plain-text">
        <xsl:text> </xsl:text><xsl:value-of select="translate(@n, $v_string-transcribe-ijmes, $v_string-transcribe-arabic)"/><xsl:text> </xsl:text>
    </xsl:template>
    <xsl:template match="text()[ancestor::tei:note[@place='bottom']]" mode="m_plain-text" priority="20"/>
    <xsl:template match="tei:note[@place='bottom']" mode="m_footnote">
        <xsl:text> </xsl:text><xsl:value-of select="translate(@n, $v_string-transcribe-ijmes, $v_string-transcribe-arabic)"/><xsl:text> </xsl:text>
       <xsl:apply-templates mode="m_footnote-text"/>
    </xsl:template>
    <!-- editorial choices -->
    <xsl:template match="tei:choice" mode="m_plain-text">
        <xsl:choose>
            <xsl:when test="tei:orig">
                <xsl:apply-templates mode="m_plain-text" select="tei:orig"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:add[@resp='#org_MS'] | tei:del[@resp='#org_MS']" mode="m_plain-text"/>
    <xsl:template match="text()" mode="m_plain-text" priority="15">
        <xsl:variable name="v_self" select="normalize-space(.)"/>
        <!-- in many instances adding whitespace before and after a text() node makes a lot of sense -->
        <!--<xsl:value-of select="translate($v_self,$v_string-normalise-shamela-arabic-source, $v_string-normalise-shamela-arabic-target)"/>-->
        <!-- remove some of the hamzas introduced by shamela.ws' transcribers -->
        <xsl:choose>
            <xsl:when test="matches($v_self,'(\W)إلى')">
                <xsl:value-of select="replace($v_self,'(\W)إلى','$1الى')"/>
            </xsl:when>
            <xsl:when test="matches($v_self,'(\W)إلي')">
                <xsl:value-of select="replace($v_self,'(\W)إلي','$1الي')"/>
            </xsl:when>
            <xsl:when test="matches($v_self,'(\W)إن')">
                <xsl:value-of select="replace($v_self,'(\W)إن','$1ان')"/>
            </xsl:when>
            <xsl:when test="matches($v_self,'(\W)أن')">
                <xsl:value-of select="replace($v_self,'(\W)أن','$1ان')"/>
            </xsl:when>
            <xsl:when test="matches($v_self,'(\W)إذ')">
                <xsl:value-of select="replace($v_self,'(\W)إذ','$1اذ')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$v_self"/>
            </xsl:otherwise>
        </xsl:choose>
         <xsl:choose>
             <xsl:when test="$v_self = ' '"/>
            <xsl:when test="ends-with($v_self,' ب')"/>
             <xsl:when test="ends-with($v_self,' ل')"/>
             <xsl:when test="ends-with($v_self,' ف')"/>
             <xsl:when test="ends-with($v_self,' و')"/>
             <xsl:otherwise>
                 <xsl:text> </xsl:text>
             </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>