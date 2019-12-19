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
    <xsl:include href="Tei2Md-parameters.xsl"/>
<!--    <xsl:include href="../../convert_tei-to-bibliographic-data/xslt/convert_tei-to-csv_functions.xsl"/>-->
        <!-- convert_tei-to-csv_functions includes all the following parameters -->
    <xsl:import href="../../tools/xslt/openarabicpe_functions.xsl"/>
    <!-- locate authority files -->
    <xsl:param name="p_path-authority-files" select="'../../authority-files/data/tei/'"/>
    <xsl:param name="p_file-name-gazetteer" select="'gazetteer_levant-phd.TEIP5.xml'"/>
    <xsl:param name="p_file-name-personography" select="'personography_OpenArabicPE.TEIP5.xml'"/>
     <!-- load the authority files -->
    <xsl:variable name="v_gazetteer"
        select="doc(concat($p_path-authority-files, $p_file-name-gazetteer))"/>
    <xsl:variable name="v_personography"
        select="doc(concat($p_path-authority-files, $p_file-name-personography))"/>
    
    <!-- variables for normalizing arabic -->
    <xsl:variable name="v_string-normalise-stylo-arabic-source" select="'اآأإئىؤة'"/>
    <xsl:variable name="v_string-normalise-stylo-arabic-target" select="'ااااييوت'"/>
    <xsl:variable name="v_string-normalise-shamela-arabic-source" select="'اآأإ'"/>
    <xsl:variable name="v_string-normalise-shamela-arabic-target" select="'اااا'"/>
    
    <!-- variables for filenames -->
    <!-- variables -->
     <xsl:variable name="vLang" select="'ar'"/>
        <xsl:variable name="vBiblStructSource"
            select="tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblStruct[1]"/>
        <xsl:variable name="vPubTitle" select="$vBiblStructSource/tei:monogr/tei:title[@xml:lang=$vLang][not(@type='sub')][1]"/>
<!--        <xsl:variable name="v_editor1" select="$vSourceBibl/tei:monogr/tei:editor/tei:persName[@xml:lang=$vLang]"/>-->
        <xsl:variable name="v_editor">
            <xsl:choose>
                <xsl:when test="$vBiblStructSource/tei:monogr/tei:editor/tei:persName[@xml:lang=$vLang]/tei:surname">
                    <xsl:value-of select="$vBiblStructSource/tei:monogr/tei:editor/tei:persName[@xml:lang=$vLang]/tei:surname"/>
                    <xsl:text>, </xsl:text>
                    <xsl:value-of select="$vBiblStructSource/tei:monogr/tei:editor/tei:persName[@xml:lang=$vLang]/tei:forename"/>
                </xsl:when>
                <xsl:when test="$vBiblStructSource/tei:monogr/tei:editor/tei:persName[@xml:lang=$vLang]">
                    <xsl:value-of select="$vBiblStructSource/tei:monogr/tei:editor/tei:persName[@xml:lang=$vLang]"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="vPubDate" select="$vBiblStructSource/tei:monogr/tei:imprint/tei:date[1]/@when"/>
    <xsl:variable name="v_id-oclc" select="$vBiblStructSource/descendant::tei:idno[@type='OCLC'][1]"/>
    <xsl:variable name="v_issue">
            <xsl:choose>
                <!-- check for correct encoding of issue information -->
                <xsl:when test="$vBiblStructSource//tei:biblScope[@unit = 'issue']/@from = $vBiblStructSource//tei:biblScope[@unit = 'issue']/@to">
                    <xsl:value-of select="$vBiblStructSource//tei:biblScope[@unit = 'issue']/@from"/>
                </xsl:when>
                <!-- check for ranges -->
                <xsl:when test="$vBiblStructSource//tei:biblScope[@unit = 'issue']/@from != $vBiblStructSource//tei:biblScope[@unit = 'issue']/@to">
                    <xsl:value-of select="$vBiblStructSource//tei:biblScope[@unit = 'issue']/@from"/>
                    <!-- probably an en-dash is the better option here -->
                    <xsl:text>-</xsl:text>
                    <xsl:value-of select="$vBiblStructSource//tei:biblScope[@unit = 'issue']/@to"/>
                </xsl:when>
                <!-- fallback: erroneous encoding of issue information with @n -->
                <xsl:when test="$vBiblStructSource//tei:biblScope[@unit = 'issue']/@n">
                    <xsl:value-of select="$vBiblStructSource//tei:biblScope[@unit = 'issue']/@n"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="v_volume">
            <xsl:choose>
                <!-- check for correct encoding of volume information -->
                <xsl:when test="$vBiblStructSource//tei:biblScope[@unit = 'volume']/@from = $vBiblStructSource//tei:biblScope[@unit = 'volume']/@to">
                    <xsl:value-of select="$vBiblStructSource//tei:biblScope[@unit = 'volume']/@from"/>
                </xsl:when>
                <!-- check for ranges -->
                <xsl:when test="$vBiblStructSource//tei:biblScope[@unit = 'volume']/@from != $vBiblStructSource//tei:biblScope[@unit = 'volume']/@to">
                    <xsl:value-of select="$vBiblStructSource//tei:biblScope[@unit = 'volume']/@from"/>
                    <!-- probably an en-dash is the better option here -->
                    <xsl:text>-</xsl:text>
                    <xsl:value-of select="$vBiblStructSource//tei:biblScope[@unit = 'volume']/@to"/>
                </xsl:when>
                <!-- fallback: erroneous encoding of volume information with @n -->
                <xsl:when test="$vBiblStructSource//tei:biblScope[@unit = 'volume']/@n">
                    <xsl:value-of select="$vBiblStructSource//tei:biblScope[@unit = 'volume']/@n"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
    
    <xsl:variable name="v_file-name-base">
            <xsl:choose>
                <xsl:when test="$p_output-format = 'md'">
                    <xsl:value-of select="concat('md/',$v_id-file)"/>
                </xsl:when>
                <xsl:when test="$p_output-format = 'stylo'">
                    <!-- author, file, div -->
                    <xsl:value-of select="'stylo/'"/>
                    <xsl:choose>
                        <xsl:when test="$v_editor/descendant-or-self::tei:persName/@ref">
                            <xsl:value-of select="concat('oape', $v_separator-attribute-value)"/>
                            <xsl:value-of select="oape:query-personography($v_editor/descendant-or-self::tei:persName[1],$v_personography,'oape','')"/>
                        </xsl:when>
                        <xsl:when test="$v_editor/descendant-or-self::tei:surname">
                            <xsl:value-of select="$v_editor/descendant-or-self::tei:surname"/>
                        </xsl:when>
                        <xsl:when test="$v_editor/descendant-or-self::tei:persName">
                            <xsl:value-of select="$v_editor/descendant-or-self::tei:persName"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>NN</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:value-of select="$v_separator-attribute-key"/>
                    <xsl:choose>
                        <xsl:when test="$v_volume = ''">
                            <xsl:value-of select="$v_id-file"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="concat('oclc',$v_separator-attribute-value,$v_id-oclc,$v_separator-attribute-key,'v',$v_separator-attribute-value,translate($v_volume,'/','-'),$v_separator-attribute-key,'i',$v_separator-attribute-value, $v_issue)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
    
    <!-- heads -->
    
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
        <!-- in many instances adding whitespace before and after a text() node makes a lot of sense -->
        <xsl:variable name="v_self" select="normalize-space(.)"/>
        <xsl:choose>
            <xsl:when test="$p_output-format = 'stylo'">
                <xsl:value-of select="translate($v_self, $v_string-normalise-stylo-arabic-source, $v_string-normalise-stylo-arabic-target)"/>
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
    <!-- prevent output from sections of articles. Why would one do that? -->
<!--    <xsl:template match="tei:div[@type = 'section'][ancestor::tei:div[@type = 'article']]" mode="mPlainText"/>-->

    <xsl:function name="oape:generate-yaml-for-div">
        <xsl:param name="p_input"/>
        <xsl:text>---</xsl:text><xsl:value-of select="$v_new-line"/>
        <xsl:text>title: "*</xsl:text><xsl:value-of select="normalize-space(replace(oape:get-title-from-div($p_input),'#',''))"/><xsl:text>*. </xsl:text><xsl:value-of select="$vPubTitle"/><xsl:text> </xsl:text><xsl:value-of select="$v_volume"/><xsl:text>(</xsl:text><xsl:value-of select="$v_issue"/><xsl:text>)</xsl:text><xsl:text>"</xsl:text><xsl:value-of select="$v_new-line"/>
        <xsl:text>author: </xsl:text><xsl:value-of select="$v_new-line"/>
        <xsl:text>    - </xsl:text><xsl:value-of select="oape:get-author-from-div($p_input)"/><xsl:value-of select="$v_new-line"/>
        <xsl:text>    - </xsl:text><xsl:value-of select="$v_editor"/><xsl:value-of select="$v_new-line"/>
        <xsl:text>date: </xsl:text><xsl:value-of select="$vPubDate"/><xsl:value-of select="$v_new-line"/>
        <xsl:text>bibliography: </xsl:text><xsl:value-of select="concat($v_id-file,'-',$p_input/@xml:id,'.bib')"/><xsl:value-of select="$v_new-line"/>
        <xsl:text>---</xsl:text><xsl:value-of select="$v_new-line"/><xsl:value-of select="$v_new-line"/>
    </xsl:function>
    <xsl:function name="oape:get-title-from-div">
        <xsl:param name="p_input"/>
            <xsl:if test="$p_input/@type = 'item' and $p_input/ancestor::tei:div[@type = 'section']">
                <xsl:apply-templates select="$p_input/ancestor::tei:div[@type = 'section']/tei:head"
                    mode="m_markdown"/>
                <xsl:text>: </xsl:text>
            </xsl:if>
            <xsl:apply-templates select="$p_input/tei:head" mode="m_markdown"/>
    </xsl:function>
    <!-- function to get the author(s) of a div -->
    <xsl:function name="oape:get-author-from-div">
        <xsl:param name="p_input"/>
        <xsl:choose>
            <xsl:when
                test="$p_input/child::tei:byline/descendant::tei:persName[not(ancestor::tei:note)]">
                <xsl:copy-of
                    select="$p_input/child::tei:byline/descendant::tei:persName[not(ancestor::tei:note)]"
                />
            </xsl:when>
            <xsl:when
                test="$p_input/child::tei:byline/descendant::tei:orgName[not(ancestor::tei:note)]">
                <xsl:copy-of
                    select="$p_input/child::tei:byline/descendant::tei:orgName[not(ancestor::tei:note)]"
                />
            </xsl:when>
            <xsl:when
                test="$p_input/descendant::tei:note[@type = 'bibliographic']/tei:bibl/tei:author">
                <xsl:copy-of
                    select="$p_input/descendant::tei:note[@type = 'bibliographic']/tei:bibl/tei:author/descendant::tei:persName"
                />
            </xsl:when>
            <xsl:when
                test="$p_input/descendant::tei:note[@type = 'bibliographic']/tei:bibl/tei:title[@level = 'j']">
                <xsl:copy-of
                    select="$p_input/descendant::tei:note[@type = 'bibliographic']/tei:bibl/tei:title[@level = 'j']"
                />
            </xsl:when>
        </xsl:choose>
    </xsl:function>
</xsl:stylesheet>
