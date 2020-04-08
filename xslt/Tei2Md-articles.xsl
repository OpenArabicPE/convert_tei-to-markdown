<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:oape="https://openarabicpe.github.io/ns"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="2.0">
    <xsl:output method="text" encoding="UTF-8" indent="yes" omit-xml-declaration="yes"/>
    <xsl:strip-space elements="*"/>
    
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>This stylesheet produces a simple markdown file from TEI XML input for every div in the body of the document</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:include href="Tei2Md-functions.xsl"/>
    <!-- functions to generate YAML block -->
    <xsl:include href="../../convert_tei-to-bibliographic-data/xslt/convert_tei-to-biblstruct_functions.xsl"/>
    <xsl:import href="../../convert_tei-to-bibliographic-data/xslt/convert_tei-to-yaml_functions.xsl"/>

    <xsl:template match="/">
            <xsl:apply-templates select="descendant::tei:text" mode="m_markdown"/>
    </xsl:template>

    <!-- there should be no MD file for sections -->
    <!-- tei:div[@type = 'section'][not(ancestor::tei:div[@type = 'article'])] |  -->
    <xsl:template
        match=" tei:div[@type = ('article', 'item')][not(ancestor::tei:div[@type = 'bill'])] | 
         tei:div[@type = ('article', 'item')][not(ancestor::tei:div[@type = 'item'][@subtype='bill'])] | 
        tei:div[@type = 'bill'] | 
        tei:div[@type = 'item'][@subtype='bill']" mode="m_markdown">
        <!-- variables identifying the digital surrogate -->
        <xsl:variable name="v_author">
            <xsl:copy-of select="oape:get-author-from-div(.)"/>
        </xsl:variable>
        
        <!-- generate the md file -->
<!--        <xsl:result-document href="../jekyll/_posts/{concat($vPublDate/@when,'-',translate($vArticleTitle,' ','-'),'-',$v_id-file,'-',@xml:id)}.md" method="text">-->
        <xsl:variable name="v_file-name">
            <xsl:choose>
                <xsl:when test="$p_output-format = 'md'">
                    <xsl:value-of select="concat($v_file-name-base,'-',@xml:id,'.md')"/>
                </xsl:when>
                <xsl:when test="$p_output-format = 'stylo'">
                    <!-- author, file, div -->
                    <xsl:value-of select="concat('stylo/articles/w_',$p_minimal-article-length,'/')"/>
                    <!--<xsl:message>
                        <xsl:copy-of select="$v_author"/>
                    </xsl:message>-->
                    <xsl:choose>
                        <xsl:when test="$v_author/descendant-or-self::tei:persName/@ref">
                            <xsl:value-of select="concat('oape', $v_separator-attribute-value)"/>
                            <xsl:value-of select="oape:query-personography($v_author/descendant-or-self::tei:persName[@ref][1],$v_personography,'oape','')"/>
                        </xsl:when>
                        <xsl:when test="$v_author/descendant-or-self::tei:surname">
                            <xsl:value-of select="$v_author/descendant-or-self::tei:surname"/>
                        </xsl:when>
                        <xsl:when test="$v_author/descendant-or-self::tei:persName">
                            <xsl:value-of select="$v_author/descendant-or-self::tei:persName"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>NN</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:value-of select="concat($v_separator-attribute-key, 'oclc',$v_separator-attribute-value,$v_id-oclc,$v_separator-attribute-key,'v',$v_separator-attribute-value,translate($v_volume,'/','-'),$v_separator-attribute-key,'i',$v_separator-attribute-value, $v_issue,$v_separator-attribute-key,@xml:id,'.txt')"/>
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
        <xsl:variable name="v_length" select="number(count(tokenize(string(.), '\W+')))"/>
        <!-- if the output format is 'stylo' then articles should be checked for minimum length -->
        <xsl:choose>
            <xsl:when test="$p_output-format = 'stylo'">
                <xsl:if test="$v_length &gt;= $p_minimal-article-length">
                    <xsl:result-document href="../_output/{$v_file-name}" method="text">
                <!-- text body -->
                    <xsl:apply-templates mode="m_markdown"/>
                </xsl:result-document>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:result-document href="../_output/{$v_file-name}" method="text">
            <!-- some metadata on the file itself: YAML. In order to support pandoc conversions etc. the Yaml block should also containe a link to the BibTeX file identifying this article. -->
            <xsl:if test="$v_include-yaml = true()">
                <xsl:text>---</xsl:text><xsl:value-of select="$v_new-line"/>
                <xsl:copy-of select="oape:bibliography-tei-to-yaml(oape:bibliography-tei-div-to-biblstruct(.), @xml:lang)"/><xsl:value-of select="$v_new-line"/>
                <xsl:text>---</xsl:text><xsl:value-of select="$v_new-line"/><xsl:value-of select="$v_new-line"/>
            </xsl:if>
            <!-- text body -->
            <xsl:apply-templates mode="m_markdown"/>
            <!-- notes -->
                    <xsl:value-of select="$v_new-line"/><xsl:value-of select="$v_new-line"/>
                    <xsl:call-template name="t_notes"/>
        </xsl:result-document>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
