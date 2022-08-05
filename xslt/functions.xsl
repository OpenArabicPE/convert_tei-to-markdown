<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:oape="https://openarabicpe.github.io/ns"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="3.0">
    <xsl:output method="text" encoding="UTF-8" indent="yes" omit-xml-declaration="yes" name="text"/>
    <xsl:strip-space elements="*"/>
    
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>This stylesheet provides functions/templates for converting TEI XML to (multi)markdown</xd:p>
        </xd:desc>
    </xd:doc>
    
    <!-- import functions -->
    <xsl:import href="parameters.xsl"/>
    <!-- functions to generate YAML block -->
    <xsl:include href="../../convert_tei-to-bibliographic-data/xslt/convert_tei-to-biblstruct_functions.xsl"/>
    <xsl:import href="../../convert_tei-to-bibliographic-data/xslt/convert_tei-to-yaml_functions.xsl"/>
    
    <xsl:template match="tei:head" mode="m_markdown">
        <!-- establish the level of nesting -->
        <xsl:variable name="v_level" select="number(count(ancestor::tei:div))"/>
        <xsl:value-of select="$v_new-line"/>
        <xsl:value-of select="$v_new-line"/>
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
        <xsl:apply-templates mode="m_markdown"/>
        <xsl:value-of select="$v_new-line"/>
        <xsl:value-of select="$v_new-line"/>
    </xsl:template>
    
    <!-- paragraphs, lines and other block-level elements -->
    <xsl:template match="tei:p | tei:l | tei:byline | tei:closer | tei:opener | tei:salute" mode="m_markdown">
        <xsl:value-of select="$v_new-line"/>
        <xsl:apply-templates mode="m_markdown"/>
        <xsl:value-of select="$v_new-line"/>
    </xsl:template>
    
    <!-- page breaks, line breaks etc. -->
    <xsl:template match="tei:lb | tei:cb | tei:pb" mode="m_markdown">
        <xsl:text> </xsl:text>
    </xsl:template>
    
    <!-- segments of a line -->
    <xsl:template match="tei:l[@type='bayt']/tei:seg" mode="m_markdown">
        <xsl:apply-templates mode="m_markdown"/>
        <xsl:text> </xsl:text>
    </xsl:template>
    
    <!-- tables -->
    <xsl:template match="tei:table" mode="m_markdown">
        <xsl:value-of select="$v_new-line"/>
        <xsl:apply-templates mode="m_markdown"/>
        <xsl:value-of select="$v_new-line"/>
        <xsl:value-of select="$v_new-line"/>
    </xsl:template>
    <xsl:template match="tei:row[@role='label']" mode="m_markdown">
        <xsl:value-of select="$v_new-line"/>
        <xsl:apply-templates mode="m_markdown"/>
        <!--<xsl:for-each select="tei:cell">
            <xsl:apply-templates mode="mPlainText"/><xsl:if test="position()!=last()"><xsl:text> | </xsl:text></xsl:if>
        </xsl:for-each>-->
        <!-- dividing row -->
        <xsl:value-of select="$v_new-line"/>
        <xsl:for-each select="tei:cell">
            <xsl:text>|-</xsl:text><xsl:if test="last()"><xsl:text>|</xsl:text></xsl:if>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="tei:row[@role='data']" mode="m_markdown">
        <xsl:value-of select="$v_new-line"/>
        <xsl:apply-templates mode="m_markdown"/>
        <!--<xsl:for-each select="tei:cell">
            <xsl:apply-templates mode="mPlainText"/><xsl:if test="position()!=last()"><xsl:text> | </xsl:text></xsl:if>
        </xsl:for-each>-->
    </xsl:template>
    
    <xsl:template match="tei:cell" mode="m_markdown">
        <xsl:text>| </xsl:text><xsl:apply-templates mode="m_markdown"/><xsl:if test="last()"><xsl:text> |</xsl:text></xsl:if>
    </xsl:template>
    
    <!-- lists -->
    <xsl:template match="tei:list" mode="m_markdown">
        <xsl:value-of select="$v_new-line"/>
        <xsl:apply-templates mode="m_markdown"/>
        <xsl:value-of select="$v_new-line"/>
        <xsl:value-of select="$v_new-line"/>
    </xsl:template>
    <xsl:template match="tei:list/tei:item" mode="m_markdown">
        <xsl:value-of select="$v_new-line"/>
        <xsl:text>- </xsl:text><xsl:apply-templates mode="m_markdown"/>
    </xsl:template>
    
    <!-- notes -->
    <xsl:template match="tei:note" mode="m_markdown">
        <xsl:choose>
            <xsl:when test="$p_output-format = 'stylo'"/>
            <xsl:otherwise>
                <xsl:variable name="v_number" select="number(count(preceding::tei:note[ancestor::tei:text]))+1"/>
        <xsl:text>[^</xsl:text><xsl:value-of select="$v_number"/><xsl:text>]</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="t_notes">
        <xsl:value-of select="$v_new-line"/>
        <xsl:value-of select="$v_new-line"/>
        <xsl:text># notes</xsl:text>
        <xsl:value-of select="$v_new-line"/>
        <xsl:apply-templates select="descendant::tei:note" mode="mNotes"/>
    </xsl:template>
    <xsl:template match="tei:note" mode="mNotes">
        <xsl:variable name="v_number" select="number(count(preceding::tei:note[ancestor::tei:text]))+1"/>
        <xsl:value-of select="$v_new-line"/>
        <xsl:text>[^</xsl:text><xsl:value-of select="$v_number"/><xsl:text>]: </xsl:text><xsl:apply-templates mode="mPlainText"/>
    </xsl:template>
    
    <!-- foreign -->
    <!--<xsl:template match="tei:foreign" mode="mPlainText">
        <xsl:text>*</xsl:text><xsl:apply-templates mode="mPlainText"/><xsl:text>*</xsl:text>
    </xsl:template>-->
    <!-- @rend: brackets and quotations marks -->
    <xsl:template match="*[@rend='brackets']" mode="m_markdown" priority="100">
        <xsl:text>(</xsl:text><xsl:apply-templates mode="m_markdown"/><xsl:text>)</xsl:text>
    </xsl:template>
    <xsl:template match="*[@rend='quotation-marks']" mode="m_markdown" priority="100">
        <xsl:text>"</xsl:text><xsl:apply-templates mode="m_markdown"/><xsl:text>"</xsl:text>
    </xsl:template>
    
    <!-- gap -->
    <xsl:template match="tei:gap" mode="m_markdown">
        <xsl:text> [...] </xsl:text>
    </xsl:template>
    
    <!-- links -->
    <xsl:template name="t_links">
        <xsl:param name="p_content"/>
        <xsl:param name="p_url"/>
        <xsl:choose>
            <xsl:when test="$p_output-format = 'stylo'">
                <xsl:apply-templates select="$p_content" mode="m_plain-text"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>[</xsl:text><xsl:apply-templates select="$p_content" mode="m_markdown"/><xsl:text>](</xsl:text><xsl:value-of select="$p_url"/><xsl:text>)</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="tei:ref[@target]" mode="m_markdown">
        <xsl:call-template name="t_links">
            <xsl:with-param name="p_content">
                <xsl:value-of select="."/>
            </xsl:with-param>
            <xsl:with-param name="p_url" select="@target"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="node()[not(self::tei:pb)][@corresp]" mode="m_markdown">
        <xsl:call-template name="t_links">
            <xsl:with-param name="p_content">
                <xsl:value-of select="."/>
            </xsl:with-param>
            <xsl:with-param name="p_url" select="@corresp"/>
        </xsl:call-template>
    </xsl:template>
    
    <!-- editorial corrections with choice: original mistakes are encoded as <sic> or <orig>, corrections as <corr> -->
    <xsl:template match="tei:choice[child::tei:corr[@resp!='#org_MS']]" mode="m_markdown">
        <xsl:choose>
            <xsl:when test="$p_display-editorial-corrections = true()">
                <xsl:apply-templates select="tei:corr" mode="m_markdown"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="node()[not(self::tei:corr)]" mode="m_markdown"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- plain text -->
    <xsl:template match="text()" mode="m_markdown m_plain-text" priority="10">
        <xsl:variable name="v_self" select="normalize-space(.)"/>
        <xsl:choose>
            <xsl:when test="$p_output-format = 'stylo'">
                <xsl:value-of select="translate($v_self, $v_string-normalise-stylo-arabic-source, $v_string-normalise-stylo-arabic-target)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$v_self"/>
            </xsl:otherwise>
        </xsl:choose>
        <!-- in many instances adding whitespace before and after a text() node makes a lot of sense -->
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
    <!-- prevent output from sections of articles. Why would one do that? -->
<!--    <xsl:template match="tei:div[@type = 'section'][ancestor::tei:div[@type = 'article']]" mode="mPlainText"/>-->
   
</xsl:stylesheet>
